# Lessons Learned — Sovereign AI Stack

Real failures, real fixes, in the order they cost time. The Decision Log in the
spec covers the *architectural* pivots (TRT-LLM → vLLM etc.); this file covers
the operational traps.

## Ops

**Cron jobs fail silently if the binary isn't on cron's PATH.** Our restic
backup logged `command not found` every Sunday for 2.5 weeks before anyone
looked — restic lived in `~/.local/bin`, which cron doesn't search. Fixes:
absolute paths in every cron-invoked script, AND a watchdog that checks
*outcomes* (latest snapshot age < 8 days), not just exit codes. Automation you
don't monitor is automation you don't have.

**Docker bypasses UFW.** Docker inserts its iptables rules ahead of UFW, so any
`ports: "9000:9000"` publish binds 0.0.0.0 and is reachable from the LAN no
matter what your firewall says. Fix: a DOCKER-USER chain policy in
`/etc/ufw/after.rules` (allow tailscale0 + established + docker bridges, drop
the rest) — see `scripts/harden-docker-firewall.sh`. Verify from a device that
is on the LAN but NOT on the tailnet.

**Backups must cover what's irreplaceable, not what's convenient.** First
backup scope covered configs and logs but missed hand-written worker code,
voice profiles, and workflow JSONs. Inventory by "can I re-download this?" —
everything that answers no goes in.

## vLLM / RTX 5090 (Blackwell SM_120)

**Stable vLLM releases lack SM_120 kernels** — use nightly/cu130 images or
pinned versions known to include them, or you get `no kernel image available`
at first inference, not at load.

**FlashInfer MoE is broken on consumer Blackwell — but don't force a workaround.**
`--moe-backend triton` / `VLLM_USE_FLASHINFER_MOE_FP4=1` is *not* the fix (triton
isn't supported for NVFP4 MoE). Just **don't set the FlashInfer MoE env vars** and let
vLLM auto-select the correct NVFP4 MoE backend for SM120. Confirmed on RTX 5090 in
[vllm#34452](https://github.com/vllm-project/vllm/issues/34452). *(Updated 2026-06-27:
this lesson originally recommended `--moe-backend triton`; that was removed in compose
v1.5.1 once vLLM's auto-selection was confirmed working.)*

**Total per-sequence VRAM is the real concurrency limit, not attention-KV.**
Weights fitting means nothing; 3-5 concurrent long-context sessions is the
practical ceiling at NVFP4, and beyond it throughput collapses to 1-2 tok/s, it
doesn't degrade gracefully. NOTE (2026-06-21): earlier docs blamed "KV-cache
thrash." Nemotron is a NemotronH Mamba-2/Transformer hybrid — only 6 of 52
layers attend, so attention-KV is tiny (~3 KB/token). What actually fills VRAM
per concurrent session is the per-sequence Mamba state + activations + the small
KV slice. Same ceiling, correct cause. See
theinvalid.me/blog/i-had-my-kv-cache-math-14x-wrong.

**`--video-pruning-rate 0.0` (EVS off) for forensic work** — the default frame
pruning trades exactly the details you're being paid to capture, for ~30%
speed.

## Hermes / LiteLLM integration

**`fallback_providers` is a top-level profile key, not nested under `model`.**
The nested form is silently ignored — your fallback chain doesn't exist and you
find out when the GPU is busy.

**Profile-scoped `.env` files pre-empt the global one.** When a profile
override is active, `HERMES_HOME` is set before dotenv loads, so the global
`~/.hermes/.env` never loads. Every profile that references an env var needs
its own `.env`.

**Provider slug is `custom`, not `openai_compatible`** (dropped from canonical
providers in v0.14).

**LiteLLM's database image ignores a mounted config without an explicit
`--config` flag** — it starts in database-only mode and every request 400s with
"Invalid model name". Always set `command: --port 4000 --config
/app/config.yaml`.

**Pin the dashboard session token.** Hermes mints a fresh random token per
start; remote clients store it; every restart breaks pairing unless
`HERMES_DASHBOARD_SESSION_TOKEN` is pinned.

## General

**LLM enthusiasm is a red flag.** If a model recommends a tool with zero
trade-offs mentioned, demand the trade-offs before acting. Every adoption here
went through five questions: tier? overlap? hardware fit? sovereignty cost?
reversibility? The stack has stayed lean because most candidates failed
question 2.

**Specs drift from reality the day you stop updating them.** The audio
companion spec said "Planned" for three weeks after the system was built and
verified. Status lives in ONE place (an execution plan / status file), specs
carry design.
