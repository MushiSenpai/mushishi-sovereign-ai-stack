#!/bin/bash
# client-job.sh — Full forensic analysis pipeline for one client video
# Usage: ./client-job.sh /mnt/client-videos/job-001.mp4 job-001
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

if [ $# -lt 2 ]; then
  echo "Usage: $0 <video_path> <job_id>"
  exit 1
fi

VIDEO="$1"
JOB_ID="$2"
OUTPUT_DIR="/data/ai/08-portfolio/forensic/$JOB_ID"

echo -e "${YELLOW}=== Client Job: $JOB_ID ===${NC}"
echo "Source: $VIDEO  →  Output: $OUTPUT_DIR"
echo ""

if ! curl -s http://localhost:8000/v1/models > /dev/null 2>&1; then
  echo "Nemotron not running — starting forensic mode..."
  /data/ai/01-workspace/scripts/forensic-mode.sh
fi

echo -e "${YELLOW}--- Running 3-pass forensic analysis ---${NC}"
python3 /data/ai/01-workspace/nemotron-forensic/forensic_analyzer.py "$VIDEO" "$JOB_ID"

if [ -f "$OUTPUT_DIR/_final-bundle.json" ]; then
  BUNDLE_SIZE=$(du -h "$OUTPUT_DIR/_final-bundle.json" | cut -f1)
  echo ""
  echo -e "${GREEN}✅ Forensic JSON bundle complete (${BUNDLE_SIZE})${NC}"
  echo "   Bundle: $OUTPUT_DIR/_final-bundle.json"
  echo ""
  echo "Next steps:"
  echo "  1. Review $OUTPUT_DIR/_final-bundle.json"
  echo "  2. Flush VRAM:  docker stop vllm-nemotron"
  echo "  3. Load creative stack:  ./creative-mode.sh"
  echo "  4. ComfyUI workflow consumes _final-bundle.json as conditioning"
else
  echo -e "${RED}❌ Bundle not generated. Check logs.${NC}" && exit 1
fi
