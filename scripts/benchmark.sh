#!/bin/bash
# benchmark.sh — Nemotron tok/s regression detection
# Run monthly or after updates. Logs to CSV for trend analysis.
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

NEMOTRON_URL="http://localhost:8000/v1/chat/completions"
MODEL="nvidia/nemotron-3-nano-omni-30b-a3b-reasoning"
BENCH_DIR="/data/ai/04-logs/benchmarks"
CSV_FILE="$BENCH_DIR/nemotron-benchmarks.csv"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

declare -a PROMPTS=(
  "Explain quantum computing in one sentence."
  "Write a Python merge sort function with type hints, docstring, and a test case."
  "Analyze the Treaty of Westphalia's impact on modern sovereignty with 3 specific examples."
  "Find a closed-form for a_n = 2*a_{n-1} + 3*a_{n-2}, a_0=1, a_1=2. Prove by induction."
)

mkdir -p "$BENCH_DIR"
[ ! -f "$CSV_FILE" ] && echo "timestamp,test_id,prompt_tok,completion_tok,time_s,tok_per_s,power_w,temp_c,throttle" > "$CSV_FILE"

echo -e "${YELLOW}=== Nemotron Benchmark Suite — $TIMESTAMP ===${NC}"
TOTAL_TOK=0; TOTAL_TIME=0

for i in "${!PROMPTS[@]}"; do
  TEST_ID=$((i+1))
  echo -e "${YELLOW}Test $TEST_ID/${#PROMPTS[@]}...${NC}"

  GPU_INFO=$(nvidia-smi --query-gpu=power.draw,temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "N/A,N/A")
  THROTTLE="N/A"
  POWER=$(echo "$GPU_INFO" | cut -d',' -f1 | xargs)
  TEMP=$(echo "$GPU_INFO" | cut -d',' -f2 | xargs)
  THROTTLE=$(echo "$GPU_INFO" | cut -d',' -f3 | xargs)

  START=$(date +%s.%N)
  RESP=$(curl -s "$NEMOTRON_URL" -H "Content-Type: application/json" \
    -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"${PROMPTS[$i]}\"}],\"max_tokens\":512}")
  END=$(date +%s.%N)

  TIME=$(echo "$END - $START" | bc)
  PROMPT_TOK=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin)['usage']['prompt_tokens'])" 2>/dev/null || echo "0")
  COMP_TOK=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin)['usage']['completion_tokens'])" 2>/dev/null || echo "0")
  SPEED=$(echo "scale=2; $COMP_TOK / $TIME" | bc)

  echo "  Completion: ${COMP_TOK} tok | Time: ${TIME}s | Speed: ${SPEED} tok/s"
  echo "  GPU: ${POWER}W @ ${TEMP}°C | Throttle: ${THROTTLE}"

  TOTAL_TOK=$((TOTAL_TOK + COMP_TOK))
  TOTAL_TIME=$(echo "$TOTAL_TIME + $TIME" | bc)
  echo "$TIMESTAMP,$TEST_ID,$PROMPT_TOK,$COMP_TOK,$TIME,$SPEED,$POWER,$TEMP,\"$THROTTLE\"" >> "$CSV_FILE"
  sleep 2
done

AVG=$(echo "scale=2; $TOTAL_TOK / $TOTAL_TIME" | bc)
echo ""
echo -e "${GREEN}=== Result: ${AVG} tok/s average ===${NC}"

# Degradation alert: >15% slower than historical average
if [ "$(wc -l < "$CSV_FILE")" -gt 10 ]; then
  HIST=$(tail -n 40 "$CSV_FILE" | awk -F',' '{sum+=$6; count++} END {printf "%.2f", sum/count}')
  DELTA=$(echo "scale=2; ($HIST - $AVG) / $HIST * 100" | bc)
  if (( $(echo "$DELTA > 15" | bc -l) )); then
    echo -e "${RED}⚠️  DEGRADATION: ${DELTA}% slower than historical avg (${HIST} tok/s)${NC}"
    echo "Check: thermal throttling, background processes, recent driver/Docker updates."
  fi
fi

echo "Logged to: $CSV_FILE"
