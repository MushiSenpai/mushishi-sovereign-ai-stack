# 🧠 Mushishi Sovereign AI Stack — Complete Setup Plan
> **Version:** 1.7.1 | **Updated:** June 10, 2026 | **Status:** Phases 0–4.5 complete, Phase 5 partial
> v1.7.1 (Jun 10, 2026): **Truth-pass patch.** (1) Restic backup had been SILENTLY FAILING since
> May 23 — cron's PATH lacks `~/.local/bin` where restic lives. Fixed: absolute path in backup.sh
> + crontab; coverage expanded (audio gateway code, nemotron-forensic, comfyui/user, voice
> profiles, full 08-portfolio); verified snapshot taken. Lesson: **cron jobs must use absolute
> binary paths and their logs must be checked after the first scheduled run.** (2) Docker-published
> ports (0.0.0.0) bypass UFW — LAN devices could reach ComfyUI/LiteLLM/etc. Fix script:
> `scripts/harden-docker-firewall.sh` (DOCKER-USER chain, ufw-docker pattern) — run with sudo.
> (3) ComfyUI workflows now in local git (remote push pending). (4) Cross-stack execution plan
> created at `~/Documents/EXECUTION-PLAN.md` — that file, not this header, now tracks what's next.
> v1.7 (Jun 4, 2026): Mac cockpit migrated from third-party `outsourc-e/hermes-workspace` PWA (:3001) to the **official Nous Research Hermes Desktop** in Remote Gateway mode. mushishi keeps the agent; Mac is a thin Electron client over Tailscale. `hermes-dashboard` reconfigured: bound to tailscale IP, `--tui` added (mandatory for remote chat), pinned `HERMES_DASHBOARD_SESSION_TOKEN`. `hermes-workspace.service` retired; :3001 freed. Gateway (:8642) untouched; all three profiles + LiteLLM routing unchanged. See Decision Log §v1.7-1.
>
> **Changes in v1.6.4:**
> v1.6.4 (May 22, 2026): Phases 3, 4, 4.5 COMPLETE. CPU Nemotron now PRISM-abliterated. LiteLLM active as cloud budget layer (Option B: GPU→cloud→CPU for personal; uncensored/client never reach cloud). DeerFlow port corrected to :2026. Hermes profile schema corrections (provider: custom, profile-scoped LITELLM_MASTER_KEY, llama.cpp -a flag). Travel test + Antigravity confirmed. See Decision Log §v1.6.4-1 through §v1.6.4-6.
>
> **Changes in v1.6.3:**
> v1.6.3 changes (May 21, 2026): COOKIE_SECURE=0 fix (the headline — without it, the workspace PWA is unreachable over HTTP-on-Tailscale). Node 20 → Node 22 LTS. Workspace systemd ExecStart direct-node. Real Gate 2.5 test added (functional, not just is-active). Credential rotation procedure rewritten as atomic script with cross-location propagation. Dual Claude Code workflow formalized. Phase 2.5 Lessons Learned section added. See Decision Log §v1.6.3-1.
>
> **Changes in v1.6.2:**
> v1.6.2 changes: Phase 2.5 execution discoveries folded back into spec — binary path detection, NodeSource over nvm, `--insecure` dashboard flag, `HERMES_PASSWORD` requirement, .env precedence model documented. See Decision Log §v1.6.2-1.
>
> **Changes in v1.6.1:**
> - **Port collision fix:** Hermes Workspace moved from `:3000` → `:3001` (originally assumed DeerFlow would use :3000 — v1.6.4 corrects this: DeerFlow actually uses :2026). Workspace stays on :3001 regardless. See Decision Log §v1.6.1-1 and §v1.6.4-5.
> - **Firewall Tailscale branch corrected:** v1.6 patch only fixed the non-Tailscale else branch; the live Tailscale branch still had `:7860`. Now fixed.
> - **Architecture diagram, tcpdump comment, and beast-status health check** updated to correct ports.
>
> **Changes in v1.6:**
> - **Aion UI replaced with Hermes Workspace PWA** for Mac cockpit. Aion required Gemini CLI on Mac (violates Tier 1). Hermes Workspace installs as a native PWA via any Chromium browser — no extra CLI. See Decision Log §v1.6-1.
> - **Port corrections:** Hermes gateway `8642`, dashboard `9119`, workspace `3001` (moved from `3000` in v1.6.1 to avoid DeerFlow collision). See Decision Log §v1.6-1 and §v1.6.1-1.
> - **Three new systemd services on Mushishi:** `hermes-agent` (gateway), `hermes-dashboard`, `hermes-workspace`. All first-party from Nous Research.
> - **API server enabled in Hermes** (`API_SERVER_ENABLED=true`, bearer auth, CORS-scoped to Tailscale IPs). Required for PWA and Paperclip adapter.
>
> **Changes in v1.5:**
> - **Inference engine pivot: NIM/TRT-LLM → vLLM 0.20.0.** Six hours of TRT-LLM 1.3.0rc13 debugging confirmed AutoDeploy can't trace multimodal-mandatory models. NVIDIA's own benchmark paper and model card both prescribe vLLM for this model. See Decision Log §1–6.
> - **Commercial creative use case formalized as T1.** Client video work (4K, 24–60fps deliverables) drives the architecture. Forensic-detail captioning constrains downstream diffusion against hallucination. New T1 `client` Hermes profile (never falls back).
> - **Forensic multimodal pipeline:** `forensic_analyzer.py` runs three-pass orchestration (tiered inventory → parallel per-element forensic → scene consistency map) with reasoning trace captured for provenance. Tiered triage handles dense scenes (e.g. Mumbai street) without hallucinated enumeration.
> - **Workflow reframed as sequential.** Nemotron analysis → JSON to disk → flush VRAM → load creative stack. Two phases never run concurrently. Unlocks aggressive vLLM settings (180K context, FP8 KV cache, 92% GPU mem util).
> - **iGPU switch completed.** Display now on motherboard HDMI/DisplayPort driven by Ryzen 9900X3D integrated graphics. Frees ~1GB of *total* VRAM (the budget that's actually tight — NOT a meaningful KV-cache gain; see §13 correction). Verified: 524 MiB used / 32607 MiB free at idle.
> - **Mode-switch scripts:** `forensic-mode.sh`, `client-job.sh`, `creative-mode.sh` — all detect `vllm-nemotron` container, sequential workflow.
> - **Decision Log appended** at the end of document — full reasoning for the v1.4 → v1.5 pivot for GitHub publication.
>
> **Changes in v1.4:** Added Sovereignty Tier Classification (T1–T4) as a decision filter · Added Tool Evaluation Checklist as guard against hype-driven adoption · VRAM Strategy now has explicit concurrent-agent ceiling (3–5 sessions at NVFP4) · New Phase 5.5: Paperclip as T4 management plane above Hermes/DeerFlow/gstack · gstack section rewritten with softer attribution and explicit tier/overlap notes · Future Additions table updated with Paperclip and Ruflo entries
> **Changes in v1.3:** Phase 1 → NVFP4 NIM tiered deployment (NVFP4 → FP8 fallback) · VRAM strategy updated (~15-18GB weights, ~14GB KV cache headroom, 131k context) · Kimi K2.6 added as cloud fallback before Groq · gstack development layer documented · Hermes personal profile updated with Kimi K2.6 · Phase 3 Kimi K2.6 setup added
>
> **Purpose:** Standalone reference document. If context is lost, start here.
> **Companion AI:** Claude Pro (planning) — feed this doc to restart any session.
> **Reviewed by:** Claude (architect) + Gemini (initial plan + comparative research) + external LLM reviews (Kimi v1.1→v1.2, additional validation). v1.5 inference engine pivot: extensive Claude debug sessions May 14–16.

---

## ⚡ TL;DR — What We're Building

A **"Brain and Brawn"** hybrid AI command center optimized for **commercial-grade creative work + general agentic automation**:

- **Mac (2013 MBP)** = thin orchestrator. Browser, Aion UI, VS Code Remote, Claude Desktop. No local compute.
- **Linux (mushishi)** = all compute. Nemotron-3-Nano-Omni via vLLM as the multimodal analysis brain. ComfyUI + FLUX/Wan/Hunyuan as the 4K/24-60fps creative stack. Hermes Agent for general work.
- **Sequential mode of operation (v1.5):** Nemotron analyzes client input → writes forensic JSON → VRAM flushed → creative stack loaded → 4K output generated. Two phases never run concurrently.
- **Tailscale mesh** = encrypted bridge. Works at home AND when traveling with the Mac.
- **Sovereignty first** — all client video/audio stays local (T1). Cloud is speed-optional for general agent work (T2), never required for privacy.

### The use case driving the architecture (v1.5 addition)

Commercial creative work — pre-shot client video where the deliverable is **4K at 24-60fps** for advertising/movies. Typical job: client wants rain removed, a vehicle removed, an object removed — but the AI must regenerate the scene with shadow/lighting/material consistency that current diffusion models hallucinate badly. **Nemotron is the constraint generator.** It produces forensic descriptions dense enough that FLUX/Wan/Hunyuan have specifications to obey rather than space to confabulate.

---

## 🖥️ Hardware Reference

| Node | Role | Specs |
|---|---|---|
| **Mac (hub)** | Command & UI | MacBook Pro 15" Late 2013, Intel Core i7 2.3GHz, Intel Iris Pro 1536MB, 16GB DDR3, macOS Sonoma (OCLP) |
| **Linux (mushishi)** | Compute | Ryzen 9 9900X3D (with iGPU, now driving display as of v1.5), TUF X870-PLUS WIFI, 128GB RAM, RTX 5090 32GB VRAM, Ubuntu 24.04 LTS, CUDA 13.2, driver 595.71.05 |
| **Storage (Linux)** | `/data` = 1.6TB NVMe (1.2TB free), `/home` = 1.3TB NVMe, root = 196GB NVMe, external = 293GB at `/media/mushi/52B434D9B434C171` |

> **iGPU switch — COMPLETED May 16, 2026 (v1.5):** Monitor now driven by integrated Radeon graphics on motherboard HDMI/DisplayPort. RTX 5090 idle baseline: ~500 MiB used (down from ~1GB). Verified via `nvidia-smi`: 524 MiB used / 32607 MiB free at idle. BIOS Primary Display set to IGFX/iGPU. This frees ~1GB of *total* VRAM — meaningful for forensic work because total allocation is what's tight on 32GB. (An earlier note framed this as "~25K context tokens"; that was a dense-transformer KV miscalc — on the NemotronH hybrid attention-KV is tiny and not the binding constraint. See §13.)

> **Mac — OCLP + Sonoma:** After any Sonoma upgrade or OCLP update, always re-apply the Post-Install Volume Patch to restore Intel Iris Pro Metal acceleration. Verify: `system_profiler SPDisplaysDataType | grep Metal` — must show Metal support, not "Software Rendered."

> **Mac — always Intel builds:** Download **x86_64** (Intel) builds of every app. Never arm64 or Apple Silicon builds.

> **Mac — RAM threshold:** 16GB DDR3 with a real ceiling. Once active apps exceed ~14GB, swap activates and performance degrades. The RAM watcher (Phase 0) sends native notifications at 13GB (warning) and 14.5GB (critical). Priority to close: browser tabs first → VS Code → Aion UI. Never close Claude Desktop mid-session — use claude.ai web temporarily instead if RAM is critical and you must free the desktop app.

> **Mac — browser isolation:** Use a lightweight browser (Orion, Firefox, or a dedicated Chrome profile) exclusively for stack management (Netdata, Phoenix, Aion UI web). Keep research browsing in a separate process that can be killed without affecting your control plane.

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│              COMMAND HUB — macOS Sonoma (OCLP)                      │
│                                                                     │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────┐  ┌─────────────┐ │
│  │Claude Desktop│  │   Aion UI    │  │VS Code   │  │  Orion/FF   │ │
│  │ (planning)  │  │(agent cockpit│  │Remote-SSH│  │(stack mgmt) │ │
│  └─────────────┘  └──────────────┘  └──────────┘  └─────────────┘ │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  stats (menu bar) + RAM watcher launchd (13GB warn/14.5 crit)│  │
│  └──────────────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────────────┘
                           │
          ╔════════════════╧════════════════╗
          ║     SOVEREIGN BRIDGE (Tailscale) ║
          ║  mushishi → 100.x.y.z (MagicDNS) ║
          ║  Works: home LAN + hotel + cellular║
          ║  Phase 6: Headscale self-hosted   ║
          ╚════════════════╤════════════════╝
                           │
┌──────────────────────────┼──────────────────────────────────────────┐
│       COMPUTE NODE — mushishi (Ubuntu 24.04)  UFW: default-deny     │
│                          │                                          │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  T4 COORDINATION (Phase 5.5): Paperclip (:3100)              │  │
│  │  Org-chart layer above Hermes, DeerFlow, Claude Code/gstack  │  │
│  │  Budgets · heartbeats · audit trails · approval gates        │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                          │                                          │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │     GPU LAYER — RTX 5090 (32GB VRAM, power-limited ~450W)    │  │
│  │     v1.5: Display now via iGPU — full 32GB available         │  │
│  │                                                              │  │
│  │  Sequential mode of operation (one mode active at a time):   │  │
│  │  ┌──────────────────────────────────────────────────────┐    │  │
│  │  │  FORENSIC MODE (T1, client video/audio):             │    │  │
│  │  │  vLLM 0.20.0 + Nemotron-3-Nano-Omni NVFP4 (:8000)    │    │  │
│  │  │  ~28-30 GB · 180K ctx · FP8 KV · EVS off · 8 fps     │    │  │
│  │  │  Output: forensic JSON → /data/ai/08-portfolio/...   │    │  │
│  │  └──────────────────────────────────────────────────────┘    │  │
│  │             ↓ (mode switch — VRAM flushed)                   │  │
│  │  ┌──────────────────────────────────────────────────────┐    │  │
│  │  │  AGENT MODE (T1/T2 general work):                    │    │  │
│  │  │  vLLM Nemotron NVFP4, lighter config (~22 GB)        │    │  │
│  │  │  131K ctx · faster startup · 3-5 concurrent agents   │    │  │
│  │  └──────────────────────────────────────────────────────┘    │  │
│  │             ↓ (mode switch — VRAM flushed)                   │  │
│  │  ┌──────────────────────────────────────────────────────┐    │  │
│  │  │  CREATIVE MODE (consumes JSON from forensic phase):  │    │  │
│  │  │  ComfyUI + FLUX/Wan/Hunyuan · 4K 24-60fps output     │    │  │
│  │  │  T1 exception: stays alongside agent for light work  │    │  │
│  │  └──────────────────────────────────────────────────────┘    │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │           CPU+RAM LAYER — 128GB System RAM                    │  │
│  │                                                              │  │
│  │  ┌─────────────────────────────────────────────────────────┐ │  │
│  │  │  Nemotron CPU (llama.cpp, :8001) — Phase 4.5            │ │  │
│  │  │  Q4_K_M GGUF, ~60GB RAM, 10-20 tok/s, always sovereign  │ │  │
│  │  └─────────────────────────────────────────────────────────┘ │  │
│  │  ┌─────────────────────────────────────────────────────────┐ │  │
│  │  │  Hermes Agent (systemd service, :8642) v1.6             │ │  │
│  │  │  + dashboard :9119 (remote-desktop; --tui; tailscale-bound) │ │ │
│  │  │  personal:    GPU → CPU → Kimi K2.6 → Groq → OpenRouter │ │  │
│  │  │  uncensored:  GPU → CPU Nemotron → STOP (never cloud)   │ │  │
│  │  └─────────────────────────────────────────────────────────┘ │  │
│  │  ┌─────────────────────────────────────────────────────────┐ │  │
│  │  │  vLLM (creative stack LLMs — NOT agent models)          │ │  │
│  │  │  Hermes-3-8b (16GB) + Dolphin-24B-AWQ (12GB)           │ │  │
│  │  └─────────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  OBSERVABILITY LAYER                                          │  │
│  │  Netdata (:19999) — GPU/CPU/RAM/Docker live                  │  │
│  │  Arize Phoenix (:6006) — LLM traces, latency, fallbacks      │  │
│  │  benchmark.sh — monthly tok/s regression detection           │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  /data/ai/ (1.6TB NVMe)  ·  UFW: all ports via Tailscale only     │
└─────────────────────────────────────────────────────────────────────┘
                           │
          ┌────────────────┴─────────────────┐
          │  CLOUD (optional / speed only)         │
          │  1st: Kimi K2.6 (NVIDIA, multimodal)   │
          │  2nd: Groq (fast text, 14.4k req/day)  │
          │  3rd: OpenRouter (broad models, paid)  │
          │  personal profile ONLY                 │
          │  NEVER for uncensored profile          │
          └───────────────────────────────────┘
                           │
          ┌────────────────┴─────────────────┐
          │  PHASE 6 — VPS (~1 month away)   │
          │  Headscale self-hosted control    │
          │  Restic remote backup target      │
          │  Cloudflare DDNS SSH fallback     │
          └───────────────────────────────────┘
```

---

## 🛡️ Sovereignty Tier Classification

Every tool and workflow in this stack falls into one of four tiers. This guides adoption: "what tier does this fit, and is that the right tier for the work?"

| Tier | Trust boundary | Tools | Use cases |
|---|---|---|---|
| **T1 Sovereign** | Local only, never network | Hermes (uncensored profile) + Nemotron GPU/CPU | Sensitive analysis, private thought, anything you wouldn't want logged |
| **T2 Speed-optional** | Local first, cloud fallback for speed | Hermes (personal profile) full chain, DeerFlow | General agent work, research on non-sensitive material |
| **T3 Cloud-explicit** | Cloud API, sovereignty deliberately traded for capability | Claude Code, gstack, Ruflo (if adopted) | Heavy coding, SaaS dev, work where Claude's reasoning is the value |
| **T4 Coordination** | Local-hosted, orchestrates across tiers | Paperclip (Phase 5.5) | Management plane across T1–T3 |

**Rule:** When adding any tool, name its tier explicitly. If a tool claims T1 but routes through cloud APIs (e.g. Ruflo against Anthropic), it's T3 — useful, but not sovereign. Don't mix the labels.

---

## 🔍 Tool Evaluation Checklist

Before adding any new tool to this stack, run it through these five questions in order. If you can't answer all five clearly, don't adopt yet — the gap is information you need before committing.

1. **Tier:** Which sovereignty tier does this fit (T1/T2/T3/T4)? If it claims T1 or T2 but routes through any cloud API for its core function, it's T3. Don't conflate.

2. **Overlap:** Does this duplicate something already in the stack? If yes, pick one — running both creates config drift and confusion. (Examples: Ruflo vs gstack, LiteLLM vs Hermes routing, Paperclip vs Aion UI for cockpit-style use.)

3. **Hardware fit:** Does it fit the RTX 5090's ~14GB of free total VRAM after weights (for local) or your monthly cloud budget (for cloud)? (That free space is mostly activations + per-sequence Mamba state, not attention-KV, which is tiny on this hybrid — see §7/§8.) Tools that promise "60-agent swarms" or "infinite parallelism" are fanning out to cloud APIs — count the real cost.

4. **Sovereignty trade-off:** What am I trading for the capability? If the answer is "I'm sending sensitive work to a third-party API," is the work actually sensitive? Match the tool tier to the work tier.

5. **Reversibility:** How hard is it to remove if I regret it? Self-hosted single-process tools (Paperclip, DeerFlow) are easy to remove. Tools that rewrite your skill files, slash commands, or memory layer (gstack, Ruflo) leave residue. Snapshot before installing those (SDD pre-task snapshot covers this).

> **Red flag heuristic:** If an LLM recommends a tool with breathless enthusiasm and zero pushback ("logical and powerful upgrade"), demand the trade-offs before you act. Every real tool has trade-offs. Marketing copy hides them; analysis surfaces them.

---

## 🎮 VRAM Strategy (v1.5 — post-iGPU switch)

### Available budget on RTX 5090

```
Total VRAM:                       32,607 MiB
Display (iGPU now):              ~500 MiB
─────────────────────────────────────────────
Available for compute:           ~32,100 MiB
```

### Forensic Mode (T1 client video work) — NEW in v1.5

| Component | VRAM |
|---|---|
| NVFP4 weights (Nemotron-3-Nano-Omni) | ~18 GB |
| Vision encoder (C-RADIOv4-H) | ~1.2 GB |
| Audio encoder (Parakeet-TDT-0.6B-v2) | ~0.6 GB |
| CUDA graphs + activations | ~2 GB |
| Multimodal preprocessing buffers | ~1.5 GB |
| Attention-KV cache (FP8, 180K context) | <~0.6 GB (hybrid — see note) |
| Per-sequence Mamba state + activations working set + safety margin | the rest |
| **Total** | **~28-30 GB** |

> **The KV line was ~7-8 GB in earlier versions — that was a dense-transformer overestimate.** Nemotron is a NemotronH hybrid (6 of 52 layers attend), so FP8 attention-KV is ~3 KB/token (~350K tokens/GiB); 180K context is roughly half a GiB of attention-KV, not 7-8. The non-KV lines (weights, graphs, multimodal buffers, per-sequence Mamba state) are what fill the budget. See §7/§8/§13 corrections.

> **Why 180K context, not 256K (the model's `max_position_embeddings`):** The practical ceiling on 32GB is ~228K tokens — a *total-VRAM* ceiling (weights + graphs + multimodal buffers + per-sequence state), **not** a KV ceiling. 256K is the theoretical position cap. 180K leaves ~25% headroom for edge cases (heavy reasoning + reference images). Bump to 200-220K only when actual context-full / OOM errors appear. See Decision Log §7 for full math.

### Agent Mode (T1/T2 general work) — UNCHANGED concept, retuned for vLLM

| Slot | What | VRAM |
|---|---|---|
| Primary | Nemotron 3 Nano Omni **NVFP4** via vLLM 0.20.0 | ~18 GB |
| KV Cache | 131K context, lighter config | ~4 GB |
| Activations + multimodal buffers | runtime working set | ~3 GB |
| Free for additional workloads | (creative T1 exception) | ~7 GB |

> **Why NVFP4 matters for your workload:** Multiple agent sessions (Hermes + DeerFlow + gstack/Ruflo cloud agents) each maintain long conversation histories. At FP8 (~2GB KV cache free), concurrent long-context sessions push each other to system RAM — collapsing throughput from ~45 tok/s to 1-2 tok/s. At NVFP4 (~4-14GB free), you have real headroom for concurrent agentic workloads without that collapse. The 1.6× throughput improvement (~150 tok/s for text/agentic tasks) is secondary to this KV cache headroom benefit.

### Concurrent Agent Capacity (the swarm ceiling — v1.4 finding, still applies)

KV cache headroom directly limits how many agentic sessions can run concurrently on local Nemotron without performance collapse. This is **unchanged from v1.4** — the engine pivot to vLLM doesn't change the fundamental KV cache math:

| KV cache headroom | Realistic concurrent long-context sessions | Beyond ceiling |
|---|---|---|
| ~14 GB (NVFP4, agent-mode config) | 3–5 agents | Cache thrash, throughput collapse to 1–2 tok/s |
| ~7-8 GB (NVFP4 + FP8 KV, forensic-mode config) | 2-3 agents | Same collapse pattern |
| ~2 GB (any FP8-weights fallback) | 1–2 agents | Same collapse, lower ceiling |

> **v1.5 note:** Forensic-mode config (`max-num-seqs: 4`) is intentionally aligned with this ceiling — single client job at a time, no concurrent forensic requests. Don't try to run multiple `forensic_analyzer.py` invocations in parallel; they'll thrash.

For "swarm" patterns beyond this ceiling:
- Fan out via cloud chain (T2 personal profile only — Kimi K2.6 → Groq → OpenRouter)
- Or use T3 Claude Code orchestrators (gstack, Ruflo) — entirely Anthropic's cloud
- **Local "60-agent swarms" are not a realistic configuration on this hardware.** Any tool that promises this is either serializing under the hood or fanning out to a cloud API.

### Creative Mode — T1 Exception (no swap needed)
FLUX.2 4B (4GB) + Wan 2.1 1.3B (2.8GB) fit alongside Hermes-3-8b in vLLM **agent-mode only**. Not compatible with forensic-mode (which uses ~30 GB).
**Script:** `creative-mode.sh` checks estimated VRAM before deciding whether to stop Nemotron.

### Creative Mode — T2+ (swap required)
`./creative-mode.sh` stops GPU Nemotron, flushes VRAM, CPU Nemotron stays up as floor.

### Forensic → Creative handoff (NEW in v1.5)
After `forensic_analyzer.py` writes its JSON bundle to disk:
1. `docker stop vllm-nemotron` flushes the full ~30GB
2. `creative-mode.sh` brings up ComfyUI workflow at 24-30 GB usage
3. ComfyUI reads `_final-bundle.json` as conditioning input
4. No live VRAM contention between phases

### Phase 4.5 — CPU Nemotron always-on floor
Nemotron Q4_K_M via llama.cpp on port 8001. ~60GB RAM. Uncensored profile never queues — it routes GPU → CPU seamlessly.

---

## 🔀 Provider Fallback Routing

```
Profile: personal  (full nested chain)
──────────────────────────────────────
Nemotron GPU (:8000) ──YES──▶ serve here (NVFP4, ~150 tok/s, 131k ctx, sovereign)
        │ unreachable
        ▼
Nemotron CPU (:8001) ──YES──▶ serve here (GGUF Q4, ~10-20 tok/s, sovereign)
        │ unreachable
        ▼
  NVIDIA Kimi K2.6 ──YES──▶ serve here (multimodal, free, same NGC key)
  (build.nvidia.com)  │
                      │ unreachable
                      ▼
   Groq API ──────────YES──▶ serve here (fast text, free 14.4k req/day)
   (Llama 3.3 70B)    │
                      │ unreachable
                      ▼
              OpenRouter ──────────▶ serve here (paid backstop, any model)

Profile: uncensored  (T1 local only, never cloud)
───────────────────────────────────────────────
Nemotron GPU (:8000) ──YES──▶ serve here
        │ unreachable (creative mode running)
        ▼
Nemotron CPU (:8001) ──YES──▶ serve here (10-20 tok/s — always sovereign)
        │ unreachable (Phase 4.5 not set up yet)
        ▼
   QUEUE / WAIT ───────────▶ notify: "run agent-mode.sh or Phase 4.5"
   (NEVER cloud)

Profile: client  (T1 — NEW in v1.5 — forensic creative work)
───────────────────────────────────────────────
Nemotron GPU forensic config (:8000) ──YES──▶ serve here ONLY
        │ unreachable
        ▼
   ERROR — client work never falls back.
   Reason: forensic detail requires full Nemotron quality.
   Falling back to CPU GGUF or any cloud would silently degrade
   the conditioning output that ComfyUI consumes.
```

---

## 📁 Directory Reference (Linux — /data/ai/)

```
/data/ai/
├── 01-workspace/
│   ├── comfyui/
│   ├── llama.cpp/            ← Phase 4.5: CPU Nemotron binary
│   ├── vllm/
│   ├── nemotron-forensic/    ← v1.5 NEW: forensic_analyzer.py + quick_describe.py
│   │   ├── forensic_analyzer.py
│   │   └── quick_describe.py
│   ├── deerflow/             ← Phase 5
│   ├── paperclip/            ← Phase 5.5
│   ├── unsloth/              ← Phase 5 reference script
│   └── scripts/
│       ├── agent-mode.sh
│       ├── forensic-mode.sh  ← v1.5 NEW: start vLLM with forensic config
│       ├── creative-mode.sh
│       ├── client-job.sh     ← v1.5 NEW: full forensic pipeline orchestrator
│       ├── backup.sh
│       ├── benchmark.sh      ← Phase 4
│       ├── harden-firewall.sh ← Phase 0
│       ├── sdd-snapshot.sh   ← SDD
│       └── sdd-verify.sh     ← SDD
│
├── 02-models/
│   ├── vllm/ (hermes-3-8b, dolphin-24b-awq)
│   ├── flux2/ flux1/ wan22/ hunyuan15/
│   ├── clip/ vae/ lora/ esrgan/
│   ├── nemotron-nvfp4/       ← v1.5: Nemotron NVFP4 weights (21GB)
│   │   ├── modeling.py       ← Patched with **kwargs (TRT-LLM artifact, harmless for vLLM)
│   │   └── modeling.py.original
│   ├── nemotron/             ← DEPRECATED v1.5: NIM cache, kept for archive
│   └── gguf/
│       └── nemotron-omni-q4_k_m.gguf  ← Phase 4.5 (~60GB)
│
├── 04-logs/
│   ├── backup.log
│   ├── forensic-jobs/        ← v1.5 NEW: per-job execution logs
│   └── benchmarks/
│       └── nemotron-benchmarks.csv     ← Phase 4 benchmark log
│
├── 06-configs/
│   ├── creative-stack/
│   ├── vllm/                 ← creative-stack LLMs (hermes-3-8b, dolphin)
│   ├── vllm-nemotron/        ← v1.5 NEW: PRIMARY Nemotron deployment
│   │   └── docker-compose.yml
│   ├── nemotron/             ← DEPRECATED v1.5: NIM compose, kept for archive
│   ├── trtllm/               ← DEPRECATED v1.5: TRT-LLM attempt, kept for Decision Log reference
│   ├── netdata/
│   ├── phoenix/
│   ├── paperclip/            ← Phase 5.5
│   └── litellm/              ← Saved, not activated (Phase 5)
│
└── 08-portfolio/
    ├── specs/                ← SDD spec files (git repo)
    │   ├── .gitignore
    │   └── *.md
    ├── forensic/             ← v1.5 NEW: forensic_analyzer.py per-job outputs
    │   ├── job-001/
    │   │   ├── inventory.json
    │   │   ├── forensic-tier1-elem-*.json
    │   │   ├── forensic-tier2-elem-*.json
    │   │   ├── forensic-tier3-cat-*.json
    │   │   ├── consistency-map.json
    │   │   ├── reasoning-traces/    ← captured model reasoning (provenance)
    │   │   └── _final-bundle.json   ← ComfyUI consumes this
    │   └── job-002/...
    └── outputs/              ← Generated 4K deliverables for clients
```

---

## 📋 Phase Overview

| Phase | What | Est. Time | Status |
|---|---|---|---|
| **0** | Foundations + Firewall + stats + RAM watcher + Tailscale + SSH | 1.5 hr | ✅ COMPLETE (May 14, 2026) |
| **1** | **v1.5: vLLM 0.20.0 + Nemotron-3-Nano-Omni NVFP4 + forensic analyzer + mode scripts** | 2.5 hr | ✅ COMPLETE (May ~19, 2026) |
| **2** | Hermes Agent + **Hermes Workspace PWA** + 3 profiles (personal / uncensored / **client** new in v1.5) | 2.5 hr | ✅ COMPLETE (May 21, 2026, v1.6.3 — included Node migration + COOKIE_SECURE fix) |
| **3** | Kimi K2.6 + Groq + OpenRouter via LiteLLM (Option B) + Hermes wiring + fallback test | 1.5 hr | ✅ COMPLETE (May 22, 2026, v1.6.4) |
| **4** | VS Code + Netdata + Arize Phoenix + Benchmark + Backups + Travel test | 2.5 hr | ✅ COMPLETE (May 22, 2026, v1.6.4) |
| **4.5** | CPU Nemotron PRISM (llama.cpp systemd, abliterated) — last-resort floor for personal, fallback floor for uncensored | 2-3 hr | ✅ COMPLETE (May 22, 2026, v1.6.4) |
| **5** | DeerFlow (:2026) ✅ + Antigravity trial ✅ keep + LiteLLM (now ACTIVE, Phase 3) | 3-4 hr | ✅ PARTIAL — DeerFlow + Antigravity done; Paperclip (5.5) conditional, Unsloth (5.4) reference-only |
| **5.5** | Paperclip management plane (T4) — only if running 3+ agents with distinct workloads | 1-2 hr | ⬜ Conditional |
| **6** | VPS: Headscale + Remote Restic + Cloudflare DDNS (~1 month away) | 3-4 hr | ⬜ Planned |

---

---

# PHASE 0 — Foundations
> **Goal:** Firewall locked down. Mac and Linux connected via Tailscale. Password-less SSH. stats + RAM watcher running. Homebrew installed.

---

## Step 0.1 — Verify Sonoma OCLP Metal Patch (Mac — do first)

```bash
system_profiler SPDisplaysDataType | grep Metal
```

Must show Metal support, not "Software Rendered." If wrong: open OCLP → Post-Install Root Patch → Start Root Patching → Restart.

### ✅ Gate 0.1
Metal support confirmed in output.

---

## Step 0.2 — Install Homebrew on Mac

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Run the two `echo` + `eval` lines it prints at the end to add brew to PATH.

### ✅ Gate 0.2
New terminal: `brew --version` prints a version.

---

## Step 0.3 — Install `stats` + RAM Watcher Launchd (Mac)

### stats (passive monitor)
```bash
brew install stats
```
Open Stats → enable: RAM, CPU, Network. Set to Launch at Login. Disable GPU panel (Intel Iris Pro stats aren't useful).

### RAM watcher (proactive notifications)

Creates native macOS alerts at **13GB warning** (Purr sound) and **14.5GB critical** (Sosumi sound).

```bash
mkdir -p ~/.mushishi
```

Create `~/Library/LaunchAgents/com.mushishi.ram-watcher.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.mushishi.ram-watcher</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string>
        <string>-c</string>
        <string>
            PAGE_SIZE=4096
            PAGES_USED=$(vm_stat | grep "Pages active" | awk '{gsub(/\./,""); print $3}')
            PAGES_WIRED=$(vm_stat | grep "Pages wired down" | awk '{gsub(/\./,""); print $4}')
            PAGES_COMP=$(vm_stat | grep "Pages occupied by compressor" | awk '{gsub(/\./,""); print $5}')
            PAGES_WIRED=${PAGES_WIRED:-0}
            PAGES_COMP=${PAGES_COMP:-0}
            GB=$(echo "scale=2; ($PAGES_USED + $PAGES_WIRED + $PAGES_COMP) * $PAGE_SIZE / 1073741824" | bc)
            if (( $(echo "$GB > 13.0" | bc -l) )) && (( $(echo "$GB < 14.5" | bc -l) )); then
                osascript -e "display notification \"RAM at ${GB}GB — close browser tabs or VS Code soon\" with title \"Mushishi RAM Warning\" sound name \"Purr\""
            fi
            if (( $(echo "$GB >= 14.5" | bc -l) )); then
                osascript -e "display notification \"RAM CRITICAL: ${GB}GB — SWAP ACTIVE. Close apps NOW.\" with title \"Mushishi RAM Critical\" sound name \"Sosumi\""
                echo "$(date '+%Y-%m-%d %H:%M:%S') CRITICAL: ${GB}GB" >> ~/.mushishi/ram-alerts.log
            fi
        </string>
    </array>
    <key>StartInterval</key>
    <integer>30</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/ram-watcher.out</string>
    <key>StandardErrorPath</key>
    <string>/tmp/ram-watcher.err</string>
</dict>
</plist>
```

```bash
launchctl load ~/Library/LaunchAgents/com.mushishi.ram-watcher.plist
launchctl list | grep mushishi   # should appear
```

### ✅ Gate 0.3
stats appears in menu bar. `launchctl list | grep mushishi` shows the watcher loaded.

---

## Step 0.4 — Install Tailscale on Mac

```bash
brew install --cask tailscale
```

Open Tailscale → Log in → Google. Mac joins tailnet.

### ✅ Gate 0.4
`tailscale status` shows Mac node.

---

## Step 0.5 — Install Tailscale on Linux (mushishi)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
sudo systemctl enable tailscaled   # persist through power failures
```

Open the printed URL in browser → same Google account. Enable MagicDNS at https://login.tailscale.com/admin/dns.

### ✅ Gate 0.5
`ping -c 3 mushishi` from Mac gets replies.

---

## Step 0.6 — SSH Key (password-less access)

On Mac:
```bash
ssh-keygen -t ed25519 -C "mac-to-mushishi-2026"
ssh-copy-id mushi@mushishi
```

### ✅ Gate 0.6
```bash
ssh mushi@mushishi 'hostname && uptime && nvidia-smi --query-gpu=name,memory.total --format=csv,noheader'
```
All three lines, no password prompt.

---

## Step 0.7 — Firewall Hardening (Linux — run once)

> ⚠️ Run this **only after** Tailscale and SSH are working. It will lock down all ports. Verify Gate 0.6 before proceeding.

Create and run the hardening script:

```bash
nano /data/ai/01-workspace/scripts/harden-firewall.sh
```

```bash
#!/bin/bash
# harden-firewall.sh — UFW default-deny + explicit service allows
# Run ONCE. Only after Tailscale and SSH confirmed working.
set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${YELLOW}=== Mushishi Firewall Hardening ===${NC}"
read -p "Type 'mushishi' to confirm reset + harden UFW: " CONFIRM
[ "$CONFIRM" != "mushishi" ] && echo "Aborted." && exit 1

sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Detect Tailscale interface
TS_IP=$(ip addr show tailscale0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d'/' -f1)

if [ -n "$TS_IP" ]; then
    echo -e "${GREEN}Tailscale detected ($TS_IP) — restricting all services to Tailscale interface.${NC}"
    # SSH via Tailscale only
    sudo ufw allow in on tailscale0 to any port 22 proto tcp comment 'SSH (Tailscale only)'
    # AI stack services
    sudo ufw allow in on tailscale0 to any port 8000 proto tcp comment 'Nemotron via vLLM (v1.5) / NIM (legacy)'
    sudo ufw allow in on tailscale0 to any port 8001 proto tcp comment 'Nemotron CPU llama.cpp'
    sudo ufw allow in on tailscale0 to any port 8642 proto tcp comment 'Hermes gateway API (v1.6)'
    sudo ufw allow in on tailscale0 to any port 9119 proto tcp comment 'Hermes dashboard (v1.7 — remote-desktop, tailnet only)'
    # :3001 Hermes workspace PWA — RETIRED v1.7
    sudo ufw allow in on tailscale0 to any port 6006 proto tcp comment 'Arize Phoenix'
    sudo ufw allow in on tailscale0 to any port 19999 proto tcp comment 'Netdata'
    sudo ufw allow in on tailscale0 to any port 4000 proto tcp comment 'LiteLLM (Phase 5)'
    sudo ufw allow in on tailscale0 to any port 2026 proto tcp comment 'DeerFlow nginx (v1.6.4 — corrected from 3000)'
    sudo ufw allow in on tailscale0 to any port 3100 proto tcp comment 'Paperclip (Phase 5.5)'
else
    echo -e "${YELLOW}Tailscale not detected — allowing SSH on all interfaces.${NC}"
    echo "Re-run this script after Tailscale is up to restrict SSH to Tailscale only."
    sudo ufw allow 22/tcp comment 'SSH (WARNING: all interfaces — re-run after Tailscale)'
    sudo ufw allow 8000/tcp comment 'Nemotron via vLLM (v1.5) / NIM (legacy)'
    sudo ufw allow 8001/tcp comment 'Nemotron CPU'
    sudo ufw allow in on tailscale0 to any port 8642 proto tcp comment 'Hermes gateway API (v1.6)'
    sudo ufw allow in on tailscale0 to any port 9119 proto tcp comment 'Hermes dashboard (v1.7 — remote-desktop, tailnet only)'
    # :3001 Hermes workspace PWA — RETIRED v1.7
    sudo ufw allow 6006/tcp comment 'Arize Phoenix'
    sudo ufw allow 19999/tcp comment 'Netdata'
fi

# Tailscale coordination
sudo ufw allow 41641/udp comment 'Tailscale WireGuard'
# Docker inter-container
sudo ufw allow in on docker0 comment 'Docker internal'
sudo ufw logging on
sudo ufw --force enable

echo ""
echo -e "${GREEN}=== Firewall Active ===${NC}"
sudo ufw status verbose
echo ""
echo "Verify from Mac:"
echo "  ssh mushi@mushishi 'echo OK'           # should work"
echo "  curl http://mushishi:8000/v1/models    # should work (after Phase 1)"
```

```bash
chmod +x /data/ai/01-workspace/scripts/harden-firewall.sh
/data/ai/01-workspace/scripts/harden-firewall.sh
```

> **Docker + UFW note:** Docker manages its own iptables rules and can bypass UFW for container-exposed ports. The rule `allow in on docker0` handles inter-container traffic. For services exposed on `0.0.0.0`, UFW alone doesn't fully block them — Tailscale-only binding (configuring containers to bind to Tailscale IP, not 0.0.0.0) is the proper fix, documented per-service in Phases 1-4.

### ✅ Gate 0.7
`sudo ufw status verbose` shows default-deny incoming. SSH from Mac still works. Port 22 blocked from non-Tailscale IPs.

---

## Step 0.8 — Mac Aliases (complete set)

```bash
nano ~/.zshrc
```

```bash
# === MUSHISHI SOVEREIGN STACK ALIASES ===

# Core SSH
alias beast='ssh mushi@mushishi'

# Status (GPU + thermal + CPU Nemotron + Docker + RAM)
alias beast-status='ssh mushi@mushishi "\
  echo \"=== GPU ==\" && \
  nvidia-smi --query-gpu=name,memory.used,memory.free,power.draw,temperature.gpu,clocks.throttle_reasons --format=csv,noheader && \
  echo \"\" && \
  echo \"=== CPU Nemotron ==\" && \
  (systemctl is-active nemotron-cpu 2>/dev/null && echo RUNNING || echo STOPPED) && \
  echo \"\" && \
  echo \"=== Docker ==\" && \
  docker ps --format \"table {{.Names}}\t{{.Status}}\" && \
  echo \"\" && \
  echo \"=== RAM ==\" && \
  free -h | grep Mem && \
  echo \"\" && \
  echo \"=== Groq Usage ==\" && \
  echo \"(check: https://console.groq.com/settings/usage)\"\
"'

# Mode switching
alias beast-agent='ssh mushi@mushishi "/data/ai/01-workspace/scripts/agent-mode.sh"'
alias beast-creative='ssh mushi@mushishi "/data/ai/01-workspace/scripts/creative-mode.sh"'

# Logs & monitoring
alias beast-logs='ssh mushi@mushishi "journalctl -u hermes-agent -f --no-pager"'
alias beast-cpu-logs='ssh mushi@mushishi "journalctl -u nemotron-cpu -f --no-pager"'

# Backup & benchmark
alias beast-backup='ssh mushi@mushishi "/data/ai/01-workspace/scripts/backup.sh"'
alias beast-bench='ssh mushi@mushishi "/data/ai/01-workspace/scripts/benchmark.sh"'

# Observability (opens in default browser)
alias netdata='open http://mushishi:19999'
alias phoenix='open http://mushishi:6006'
alias paperclip='open http://mushishi:3100'   # Phase 5.5

# Inference tests
alias nemotron-test='curl -s http://mushishi:8000/v1/models | python3 -m json.tool'
alias nemotron-cpu-test='curl -s http://mushishi:8001/v1/models | python3 -m json.tool'

# SDD workflow
alias sdd-snap='beast "/data/ai/01-workspace/scripts/sdd-snapshot.sh"'
alias sdd-check='beast "/data/ai/01-workspace/scripts/sdd-verify.sh"'
```

```bash
source ~/.zshrc
beast-status
```

### ✅ Gate 0.8
beast-status returns GPU stats including thermal throttle reasons, CPU Nemotron status (STOPPED for now — correct), Docker containers, and RAM. Phase 0 complete ✅

---

---

# PHASE 1 — vLLM + Nemotron-3-Nano-Omni (forensic-grade multimodal)
> **Goal:** Nemotron-3-Nano-Omni NVFP4 serving on `:8000` via **vLLM 0.20.0** with forensic-tier multimodal config (180K context, FP8 KV cache, EVS disabled, 8 fps default). Forensic analyzer script in place. Mode-switch scripts working.
>
> **Why vLLM (not NIM, not TRT-LLM):** NVIDIA's own benchmark paper uses vLLM nightly for this model. HuggingFace model card explicitly requires `vLLM 0.20.0`. NVIDIA's cookbook has a complete vLLM multimodal example. TRT-LLM 1.3.0rc13 AutoDeploy can't trace multimodal-mandatory models — confirmed via 6+ hours of debug. Full reasoning preserved in **Decision Log §1–6** at the end of this document.

---

## Step 1.0 — Verify prerequisites (post-iGPU switch)

```bash
# 1. iGPU switch confirmed
nvidia-smi --query-gpu=memory.used,memory.free --format=csv,noheader
# Expected: <600 MiB used, ~32000 MiB free

# 2. NVFP4 weights present (21GB)
ls -lh /data/ai/02-models/nemotron-nvfp4/
du -sh /data/ai/02-models/nemotron-nvfp4/

# 3. Docker GPU runtime working
docker run --rm --gpus all nvidia/cuda:13.0-base-ubuntu24.04 nvidia-smi

# 4. No stale containers holding VRAM (deprecated TRT-LLM container should be down)
docker ps -a
docker stop trtllm-nemotron 2>/dev/null
docker rm trtllm-nemotron 2>/dev/null
```

### ✅ Gate 1.0 — Prerequisites
All four checks pass. RTX 5090 has ~32GB free, weights local, Docker GPU works, no stale containers.

---

## Step 1.1 — Set GPU Power Limit (persistent)

```bash
sudo nvidia-smi -pl 450

sudo tee /etc/systemd/system/nvidia-power-limit.service > /dev/null << 'EOF'
[Unit]
Description=NVIDIA GPU Power Limit
After=multi-user.target
[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pl 450
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable nvidia-power-limit
sudo systemctl start nvidia-power-limit
```

### ✅ Gate 1.1
`nvidia-smi --query-gpu=power.limit --format=csv,noheader` returns `450.00 W`.

---

## Step 1.2 — Pull vLLM 0.20.0 container

```bash
docker pull vllm/vllm-openai:v0.20.0
# ~15-20 GB download. First pull only.

docker images | grep vllm
```

### ✅ Gate 1.2
Image `vllm/vllm-openai:v0.20.0` present locally.

---

## Step 1.3 — Create vLLM compose for forensic mode

```bash
mkdir -p /data/ai/06-configs/vllm-nemotron
```

`/data/ai/06-configs/vllm-nemotron/docker-compose.yml`:

```yaml
services:
  vllm-nemotron:
    image: vllm/vllm-openai:v0.20.0
    container_name: vllm-nemotron
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=all
      # Enable FlashInfer NVFP4 MoE path (Blackwell-native)
      - VLLM_USE_FLASHINFER_MOE_FP4=1
      # Build only for SM_120 (RTX 5090) — cuts JIT compile time
      - TORCH_CUDA_ARCH_LIST=12.0
      - VLLM_LOGGING_LEVEL=INFO
    ports:
      - "8000:8000"
    volumes:
      - /data/ai/02-models/nemotron-nvfp4:/model:ro
      - /mnt:/mnt:ro                                 # client video access
      - /data/ai/08-portfolio:/portfolio:ro          # generated outputs (for validation pass)
      - vllm-hf-cache:/root/.cache/huggingface
      - vllm-vllm-cache:/root/.cache/vllm
    ipc: host
    ulimits:
      memlock: -1
      stack: 67108864
    shm_size: "16gb"
    restart: "no"
    entrypoint: /bin/bash
    command:
      - -c
      - |
        set -e
        echo "[startup] Installing audio support packages (one-time, cached after)..."
        pip install --no-cache-dir 'vllm[audio]'
        echo "[startup] Audio deps ready. Starting vLLM..."
        exec vllm serve /model \
          --served-model-name nvidia/nemotron-3-nano-omni-30b-a3b-reasoning \
          --host 0.0.0.0 \
          --port 8000 \
          --trust-remote-code \
          --max-model-len 180000 \
          --max-num-seqs 4 \
          --max-num-batched-tokens 16384 \
          --gpu-memory-utilization 0.92 \
          --kv-cache-dtype fp8 \
          --enable-prefix-caching \
          --reasoning-parser nemotron_v3 \
          --enable-auto-tool-choice \
          --tool-call-parser qwen3_coder \
          --moe-backend triton \
          --limit-mm-per-prompt '{"video": 1, "image": 8, "audio": 1}' \
          --media-io-kwargs '{"video": {"fps": 8, "num_frames": 512}}' \
          --allowed-local-media-path /mnt \
          --video-pruning-rate 0.0
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/v1/models"]
      interval: 30s
      timeout: 10s
      retries: 30
      start_period: 600s

volumes:
  vllm-hf-cache:
  vllm-vllm-cache:
```

### Parameter rationale (each flag, why this value)

| Flag | Value | Reason |
|---|---|---|
| `--max-model-len` | 180000 | Stable 180K context. Practical ceiling on 32GB at FP8 KV is ~228K. 180K = ~25% headroom. Covers 95% of client work. Bump to 200K only on real context-full errors. |
| `--max-num-seqs` | 4 | Sequential workflow (no concurrent ComfyUI). Aligns with the 3-5 agent concurrent ceiling from v1.4 VRAM analysis. |
| `--max-num-batched-tokens` | 16384 | Per-batch token cap. Conservative for long multimodal prompts. |
| `--gpu-memory-utilization` | 0.92 | Aggressive (solo operation, iGPU display, no concurrent VRAM pressure). |
| `--kv-cache-dtype` | fp8 | Halves attention-KV per token. Negligible quality impact for description tasks. (On this NemotronH hybrid only 6/52 layers attend, so attention-KV is already tiny — ~3 KB/token; this is a small saving, not the "2× context" lever earlier docs implied. Context is bound by total VRAM, not KV. See §7/§8 corrections.) |
| `--enable-prefix-caching` | on | **Critical for forensic workflow.** Multi-pass requests reuse cached video tokens: Pass 2+ are 5-7× faster. |
| `--reasoning-parser` | nemotron_v3 | Required for the model's `<think>...</think>` reasoning blocks to be parsed. |
| `--enable-auto-tool-choice` | on | Required for function-call output structure. |
| `--tool-call-parser` | qwen3_coder | Required — Nemotron's tool format aligns with Qwen3-Coder. |
| `--moe-backend` | triton | **Workaround for FlashInfer MoE bug on consumer Blackwell.** Without this, MoE inference fails on RTX 5090. |
| `--limit-mm-per-prompt` | `{video:1, image:8, audio:1}` | Per-request media caps. 8 images = main video + 6 reference images + 1 spare. |
| `--media-io-kwargs` | `{video:{fps:8, num_frames:512}}` | **Default sampling.** 8 fps captures motion for forensic description; up to 512 frames = ~64 seconds. Per-request overridable. |
| `--allowed-local-media-path` | /mnt | Allows `file:///mnt/...` URLs for local client videos. |
| `--video-pruning-rate` | 0.0 | **EVS DISABLED.** Forensic detail requires every sampled frame analyzed. (Trade: ~30% slower video inference vs default 0.5, but no missed details.) |

### Why NVFP4 specifically (not FP8 or BF16)
- **BF16** (62GB) doesn't fit on a 32GB GPU at all.
- **FP8** (33GB) would fit weights but leave almost no *total* VRAM free → no room for graphs/buffers/per-sequence state, OOM on first big tensor.
- **NVFP4** (21GB) is the only quantization giving us both: weights fit (~18GB in VRAM after engine optimization) AND ~7-8GB of *total* VRAM free for everything-that-isn't-weights → 180K context. (Earlier docs labelled that free space "KV cache headroom"; on this hybrid attention-KV is a tiny fraction of it — the headroom is mostly graphs, multimodal buffers, and per-sequence Mamba state. See §7/§8/§13.)
- **Quality:** NVIDIA states "negligible accuracy loss" between BF16 and NVFP4 for this model. Blackwell-native 4-bit block-scaled format designed for SM_120 hardware acceleration.

---

## Step 1.4 — Launch vLLM Nemotron

```bash
cd /data/ai/06-configs/vllm-nemotron
docker compose up -d
docker logs -f vllm-nemotron
```

### What to watch for in the logs

| Time | Log line | Status |
|---|---|---|
| 0:30 | `[startup] Installing audio support packages...` | Pip install begins |
| 1:30 | `[startup] Audio deps ready. Starting vLLM...` | ✅ Audio ready |
| 2:00 | `Loading model from /model` | Begin model load |
| 2:30 | `Detected NVFP4 quantization` or similar | ✅ NVFP4 active |
| 3:00 | `Loading safetensors checkpoint shards: 0/3` | Reading 21GB weights |
| 5:00 | `Loading safetensors checkpoint shards: 3/3` | Weights loaded |
| 5:30 | `Memory profiling results: ... GPU KV cache size: X tokens` | Cache allocated |
| 6:00 | `Capturing the model for CUDA graphs` | Optimizing |
| 8:00 | `Uvicorn running on http://0.0.0.0:8000` | 🎉 Ready |

Total time from `docker compose up` to ready: **~5–10 minutes** (vs ~30 min for TRT-LLM engine compile).

### ✅ Gate 1.4 — vLLM ready
`curl -s http://localhost:8000/v1/models | python3 -m json.tool` returns model JSON.

---

## Step 1.5 — Validation tests

### Test 1: text-only inference (sanity check)
```bash
curl -s http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning",
    "messages": [{"role": "user", "content": "What is 2+2? Answer briefly."}],
    "max_tokens": 100,
    "temperature": 0.2
  }' | python3 -m json.tool
```
Expected: clean text response, ~1 second.

### Test 2: image understanding (real-world test for creative use case)
```bash
curl -s http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning",
    "messages": [{
      "role": "user",
      "content": [
        {"type": "text", "text": "Describe this image in detail. Count distinct objects and describe lighting."},
        {"type": "image_url", "image_url": {"url": "https://images.unsplash.com/photo-1494526585095-c41746248156"}}
      ]
    }],
    "max_tokens": 800
  }' | python3 -m json.tool
```
Expected: detailed description, ~5-10 seconds. Output should name specific objects, count where possible, describe lighting direction.

### Test 3: VRAM check (steady state)
```bash
nvidia-smi --query-gpu=memory.used,memory.free,power.draw,temperature.gpu --format=csv,noheader
```
Target: **28-30 GB used** (NVFP4 + KV cache + activations). Above 31 GB suggests OOM risk — drop `--max-model-len` to 160000.

### Test 4: Tailscale path from Mac
```bash
# On Mac
curl -s http://mushishi:8000/v1/models | python3 -m json.tool
```
Confirms firewall + Tailscale + UFW from Phase 0 still work.

### ✅ Gate 1.5 — Multimodal validated
All four tests pass. Test 2 should clearly demonstrate the model "seeing" — specific object names, counts, spatial positions.

---

## Step 1.6 — Forensic analyzer script (T1 client work — NEW in v1.5)

This is the multi-pass orchestration script that runs for every client video job.

```bash
mkdir -p /data/ai/01-workspace/nemotron-forensic
```

Create `/data/ai/01-workspace/nemotron-forensic/forensic_analyzer.py`:

```python
#!/usr/bin/env python3
"""
Forensic video/image analyzer using Nemotron-3-Nano-Omni via vLLM.
Three-pass workflow: inventory → parallel forensic detail → consistency map.

Designed for T1 client video work where extreme detail prevents hallucination
in the downstream creative stack (ComfyUI + FLUX/Wan/Hunyuan).

Key design decisions:
- Reasoning trace captured separately from final output (provenance gold)
- Tiered reasoning budgets per pass type (deeper for hero, lighter for categories)
- Triage approach for high-density scenes (Mumbai street: 200+ elements classified
  into hero / secondary / density categories / atmospheric fields)
- Atmospheric/field elements (rain, smoke, lighting) handled as fields with
  characteristics, NOT enumerated particles
- Prefix caching via vLLM means Pass 2+ requests reuse cached video tokens
  (5-7x speedup on subsequent calls against same video)
"""

import asyncio
import json
import sys
from pathlib import Path
from openai import AsyncOpenAI

client = AsyncOpenAI(
    base_url="http://localhost:8000/v1",
    api_key="not-needed"
)

MODEL = "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning"


def make_reasoning_params(budget: int, temperature: float = 0.6):
    """NVIDIA's recommended sampling for thinking mode + tunable budget."""
    return {
        "temperature": temperature,
        "top_p": 0.95,
        "extra_body": {
            "chat_template_kwargs": {"enable_thinking": True},
            "reasoning_budget": budget,
            "grace_period": 1024,
        },
    }


def extract_reasoning_and_content(response):
    """Capture both the reasoning trace and the final output."""
    msg = response.choices[0].message
    content = msg.content or ""
    # vLLM with nemotron_v3 reasoning parser exposes reasoning_content separately
    reasoning = getattr(msg, "reasoning_content", "") or ""
    return reasoning, content


def make_media_content(file_url: str):
    """Auto-detect image vs video and return the correct vLLM content block.
    Images use image_url; videos use video_url. Sending a JPEG as video_url
    crashes vLLM's video processor with a dtype cast error."""
    ext = file_url.rsplit(".", 1)[-1].lower()
    if ext in ("jpg", "jpeg", "png", "webp", "gif", "bmp", "tiff"):
        return {"type": "image_url", "image_url": {"url": file_url}}
    else:
        return {"type": "video_url", "video_url": {"url": file_url}}


PASS1_PROMPT = """Systematically scan this media (video or image). Classify visual elements into FOUR tiers:

TIER 1 — Hero subjects (max 5):
The most prominent, individually-identifiable elements. Named, primary visual focus.
Examples: "the red Tata Nexon sedan center-frame", "the woman in blue saree at lower-right"

TIER 2 — Secondary subjects (max 15):
Distinct but less prominent. Individually describable.
Examples: "white SUV parked far-left", "billboard upper-right showing Maggi noodles"

TIER 3 — Background density categories (max 10):
Groups of similar elements counted/estimated AS GROUPS, not individually enumerated.
Examples: "~12-15 motorbikes in middle-distance traffic", "estimated 30+ pedestrians on right sidewalk"

DO NOT attempt to individually enumerate elements within Tier 3 categories.
Provide: category name, count estimate range, spatial distribution, general appearance.

TIER 4 — Atmospheric / field elements:
Environment-wide phenomena. Described as FIELDS with characteristics, NOT enumerated particles.
Examples: "rain: moderate density (~3-5mm visible droplets at ~45° angle with motion blur),
uniform across frame, slightly heavier in upper third"

Output as valid JSON only (no prose outside):
{
  "tier_1_hero": [{"id":1,"description":"...","position":"...","frames_visible":"..."}],
  "tier_2_secondary": [{"id":N,"description":"...","position":"...","frames_visible":"..."}],
  "tier_3_categories": [{"id":N,"category":"...","count_estimate":"X-Y","distribution":"...","appearance":"..."}],
  "atmospheric": [{"type":"...","characteristics":"..."}]
}
"""


PASS2_HERO_PROMPT = """Focus exclusively on element #{elem_id}: "{description}" located in the {position} area.

Provide forensic-grade detail covering:
- Exact appearance: shape, dominant color (specific shade if possible), material, texture, condition (new/worn/damaged/dirty)
- Spatial: exact position relative to frame edges and other named objects, scale relative to known references
- Motion: stationary or moving? If moving: direction, speed, acceleration, any deformation
- Lighting on it: which side is lit, shadow direction and density, reflections present, highlights
- Edges and occlusion: which parts are clipped by frame, which by other objects, any motion blur
- Surface details: text/labels/markings if any (transcribe verbatim), patterns, fabric weave, surface imperfections
- Inter-object relations: what it casts shadow onto, what reflects off it, what it occludes

Output as structured paragraphs under labeled headings. Be specific and falsifiable, not interpretive.
Count discrete features when applicable (e.g., "3 buttons", not "several buttons").
"""


PASS2_SECONDARY_PROMPT = """Element #{elem_id}: "{description}" in the {position}.

Provide focused detail covering:
- Appearance: color, material, condition
- Position and scale relative to frame
- Lighting and shadow direction on it
- Any visible text or distinguishing marks
- Inter-object relations: what does it touch, occlude, reflect, or cast shadow onto? What illuminates it?

Concise but specific. ~500-800 words of structured detail.
"""


PASS2_CATEGORY_PROMPT = """Category #{elem_id}: "{category}" — estimated count {count_estimate} in {distribution}.

For this DENSITY CATEGORY, describe:
- Representative example: one typical instance described in detail (color, type, scale)
- Variation within category: range of appearances (e.g., "motorbikes range from black/red Honda Activas to silver Royal Enfields, mostly carrying 1-2 riders")
- Edge cases: outliers or notable individual elements within the group
- Spatial distribution pattern: clustered, dispersed, in motion, parked, etc.

Do NOT enumerate individual instances. Describe statistically and representatively.
"""


PASS2_ATMOSPHERIC_PROMPT = """Atmospheric field: "{atm_type}" with characteristics: {characteristics}.

This element is an ENVIRONMENT-WIDE PHENOMENON, not a discrete object. Provide forensic-grade detail for downstream scene regeneration:

1. LIGHT SOURCES & INTERACTIONS: Identify every distinct light source contributing to this field. For each:
   - Type (practical, ambient, emissive object, reflected), color temperature (K if possible), intensity (relative scale 1-10)
   - Direction (degrees from camera, elevation), hardness (soft/hard/mixed), falloff pattern
   - What surfaces does this light hit? What color does it cast on those surfaces?
   - Caustics, volumetric scattering, or lens effects produced by this field

2. INTER-OBJECT LIGHT TRANSFER: How does light from emissive objects (screens, glowing liquids, neon, fire) affect nearby surfaces?
   - Color bleeding: which objects pick up color from which light sources?
   - Specular reflections: where are the highlights, what shape, what color?
   - Shadow layering: multiple light sources create overlapping shadows — describe the overlap regions

3. SPATIAL GRADIENT: How does this field vary across the frame?
   - Top-to-bottom, left-to-right, foreground-to-background variation
   - Any hard boundaries (window edge, doorway, lamp cone)?

4. TEMPORAL BEHAVIOR: Is this field static or changing across frames?
   - Flickering, pulsing, moving shadows, cloud movement, fire dynamics
   - Rate of change if applicable

Output as labeled sections. Be specific and falsifiable — a VFX artist must be able to recreate this lighting setup from your description alone.
"""


PASS3_CONSISTENCY_PROMPT = """You have analyzed this video in detail. The identified elements summary:

{inventory_summary}

Produce a SCENE-LEVEL CONSISTENCY MAP — the facts that any frame-by-frame regeneration of this scene MUST obey:

1. LIGHTING: Primary light source(s), direction(s) (degrees if possible), color temperature, hardness/softness, any practicals visible.
2. SHADOWS: Direction and density of shadows cast by primary elements. Any unusual shadow shapes implying off-screen geometry.
3. COLOR GRADE: Overall palette, dominant hues, saturation, contrast, color casts. Differences between shadows/midtones/highlights.
4. CAMERA: Apparent focal length (wide/normal/telephoto), height, angle, motion (static/handheld/dolly/etc.), depth of field characteristics.
5. ATMOSPHERE: Air quality (haze/clear), weather, particulates, post effects (grain/lens flare/chromatic aberration).
6. SCALE REFERENCES: Known-size objects establishing dimensional consistency.
7. AUDIO LANDSCAPE: Dominant sounds, ambient bed, any dialogue (transcribe), music presence.
8. INVARIANTS: Elements that MUST be preserved if regenerating (specific objects, positions, brand elements, signage).

Output as labeled sections. This document is the constraint set for downstream image/video regeneration.
"""


async def pass1_inventory(video_url: str, save_dir: Path):
    """Pass 1: Tiered inventory. Light reasoning budget (12K)."""
    print("[Pass 1] Running tiered inventory scan...")
    response = await client.chat.completions.create(
        model=MODEL,
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": PASS1_PROMPT},
                make_media_content(video_url)
            ]
        }],
        max_tokens=20480,
        **make_reasoning_params(budget=12288, temperature=0.3),
    )
    reasoning, content = extract_reasoning_and_content(response)

    raw = content
    if not raw or not raw.strip():
        print(f"[Pass 1] ❌ Model returned empty content. Reasoning trace length: {len(reasoning)} chars")
        if reasoning:
            print(f"[Pass 1]    First 500 chars of reasoning:\n{reasoning[:500]}")
        raise RuntimeError("Pass 1 returned empty content — model may need more max_tokens or video format is unsupported.")
    if "```json" in raw:
        raw = raw.split("```json")[1].split("```")[0]
    elif "```" in raw:
        raw = raw.split("```")[1].split("```")[0]
    try:
        inventory = json.loads(raw.strip())
    except json.JSONDecodeError as e:
        print(f"[Pass 1] ❌ JSON parse failed: {e}")
        print(f"[Pass 1]    Raw content ({len(raw)} chars):\n{raw[:1000]}")
        raise

    (save_dir / "inventory.json").write_text(json.dumps(inventory, indent=2))
    (save_dir / "reasoning-traces" / "pass1-inventory.txt").write_text(reasoning)

    t1 = len(inventory.get("tier_1_hero", []))
    t2 = len(inventory.get("tier_2_secondary", []))
    t3 = len(inventory.get("tier_3_categories", []))
    atm = len(inventory.get("atmospheric", []))
    print(f"[Pass 1] Found: {t1} hero / {t2} secondary / {t3} categories / {atm} atmospheric")
    return inventory


async def pass2_hero(video_url: str, elem: dict, save_dir: Path):
    """Pass 2 (Tier 1): Deep forensic with 24K reasoning budget."""
    elem_id = elem["id"]
    print(f"[Pass 2/hero] Analyzing #{elem_id}: {elem['description']}")
    response = await client.chat.completions.create(
        model=MODEL,
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": PASS2_HERO_PROMPT.format(
                    elem_id=elem_id, description=elem["description"], position=elem["position"])},
                make_media_content(video_url)
            ]
        }],
        max_tokens=20480,
        **make_reasoning_params(budget=24576),
    )
    reasoning, content = extract_reasoning_and_content(response)
    result = {"element_id": elem_id, "tier": 1, "description": elem["description"], "forensic_detail": content}
    (save_dir / f"forensic-tier1-elem-{elem_id}.json").write_text(json.dumps(result, indent=2))
    (save_dir / "reasoning-traces" / f"tier1-elem-{elem_id}.txt").write_text(reasoning)
    return result


async def pass2_secondary(video_url: str, elem: dict, save_dir: Path):
    """Pass 2 (Tier 2): Lighter forensic with 12K reasoning."""
    elem_id = elem["id"]
    print(f"[Pass 2/secondary] Analyzing #{elem_id}: {elem['description']}")
    response = await client.chat.completions.create(
        model=MODEL,
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": PASS2_SECONDARY_PROMPT.format(
                    elem_id=elem_id, description=elem["description"], position=elem["position"])},
                make_media_content(video_url)
            ]
        }],
        max_tokens=20480,
        **make_reasoning_params(budget=12288),
    )
    reasoning, content = extract_reasoning_and_content(response)
    result = {"element_id": elem_id, "tier": 2, "description": elem["description"], "forensic_detail": content}
    (save_dir / f"forensic-tier2-elem-{elem_id}.json").write_text(json.dumps(result, indent=2))
    (save_dir / "reasoning-traces" / f"tier2-elem-{elem_id}.txt").write_text(reasoning)
    return result


async def pass2_category(video_url: str, cat: dict, save_dir: Path):
    """Pass 2 (Tier 3): Statistical/representative with 8K reasoning."""
    cat_id = cat["id"]
    print(f"[Pass 2/category] Analyzing category #{cat_id}: {cat['category']}")
    response = await client.chat.completions.create(
        model=MODEL,
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": PASS2_CATEGORY_PROMPT.format(
                    elem_id=cat_id, category=cat["category"],
                    count_estimate=cat["count_estimate"], distribution=cat["distribution"])},
                make_media_content(video_url)
            ]
        }],
        max_tokens=12000,
        **make_reasoning_params(budget=8192),
    )
    reasoning, content = extract_reasoning_and_content(response)
    result = {"category_id": cat_id, "tier": 3, "category": cat["category"],
              "count_estimate": cat["count_estimate"], "category_detail": content}
    (save_dir / f"forensic-tier3-cat-{cat_id}.json").write_text(json.dumps(result, indent=2))
    (save_dir / "reasoning-traces" / f"tier3-cat-{cat_id}.txt").write_text(reasoning)
    return result


async def pass2_atmospheric(video_url: str, atm: dict, save_dir: Path):
    """Pass 2 (Tier 4): Deep atmospheric/lighting forensic with 16K reasoning."""
    atm_type = atm["type"]
    print(f"[Pass 2/atmospheric] Analyzing field: {atm_type}")
    response = await client.chat.completions.create(
        model=MODEL,
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": PASS2_ATMOSPHERIC_PROMPT.format(
                    atm_type=atm_type, characteristics=atm.get("characteristics", ""))},
                make_media_content(video_url)
            ]
        }],
        max_tokens=20480,
        **make_reasoning_params(budget=16384),
    )
    reasoning, content = extract_reasoning_and_content(response)
    safe_name = atm_type.replace(" ", "_").replace("/", "-")[:40]
    result = {"type": atm_type, "tier": 4, "atmospheric_detail": content}
    (save_dir / f"forensic-tier4-atm-{safe_name}.json").write_text(json.dumps(result, indent=2))
    (save_dir / "reasoning-traces" / f"tier4-atm-{safe_name}.txt").write_text(reasoning)
    return result


async def pass3_consistency(video_url: str, inventory: dict, save_dir: Path):
    """Pass 3: Global consistency map. 16K reasoning."""
    print("[Pass 3] Building scene consistency map...")
    summary_parts = []
    for elem in inventory.get("tier_1_hero", []):
        summary_parts.append(f"  - HERO #{elem['id']}: {elem['description']} ({elem['position']})")
    for elem in inventory.get("tier_2_secondary", []):
        summary_parts.append(f"  - SEC  #{elem['id']}: {elem['description']} ({elem['position']})")
    for cat in inventory.get("tier_3_categories", []):
        summary_parts.append(f"  - CAT  #{cat['id']}: {cat['category']} (~{cat['count_estimate']})")
    for atm in inventory.get("atmospheric", []):
        summary_parts.append(f"  - ATM: {atm['type']}")
    summary = "\n".join(summary_parts)

    response = await client.chat.completions.create(
        model=MODEL,
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": PASS3_CONSISTENCY_PROMPT.format(inventory_summary=summary)},
                make_media_content(video_url)
            ]
        }],
        max_tokens=20480,
        **make_reasoning_params(budget=16384),
    )
    reasoning, content = extract_reasoning_and_content(response)
    result = {"consistency_map": content}
    (save_dir / "consistency-map.json").write_text(json.dumps(result, indent=2))
    (save_dir / "reasoning-traces" / "pass3-consistency.txt").write_text(reasoning)
    return result


async def analyze_video(video_url: str, job_id: str):
    """Run full 3-pass forensic analysis on a video OR image.
    Despite the parameter name, video_url accepts both image and video
    file:// URLs — make_media_content() handles the dispatch."""
    """Full forensic analysis pipeline."""
    save_dir = Path(f"/data/ai/08-portfolio/forensic/{job_id}")
    save_dir.mkdir(parents=True, exist_ok=True)
    (save_dir / "reasoning-traces").mkdir(exist_ok=True)

    print(f"\n{'='*70}")
    print(f"Forensic analysis — Job: {job_id}")
    print(f"Source:  {video_url}")
    print(f"Output:  {save_dir}")
    print(f"{'='*70}\n")

    inventory = await pass1_inventory(video_url, save_dir)

    # Pass 2: parallel — vLLM prefix caching makes subsequent calls 5-7x faster
    hero_tasks = [pass2_hero(video_url, e, save_dir) for e in inventory.get("tier_1_hero", [])]
    sec_tasks = [pass2_secondary(video_url, e, save_dir) for e in inventory.get("tier_2_secondary", [])]
    cat_tasks = [pass2_category(video_url, c, save_dir) for c in inventory.get("tier_3_categories", [])]
    atm_tasks = [pass2_atmospheric(video_url, a, save_dir) for a in inventory.get("atmospheric", [])]
    pass2_results = await asyncio.gather(*(hero_tasks + sec_tasks + cat_tasks + atm_tasks))

    consistency = await pass3_consistency(video_url, inventory, save_dir)

    bundle = {
        "job_id": job_id,
        "video_url": video_url,
        "inventory": inventory,
        "forensic_details": pass2_results,
        "consistency_map": consistency["consistency_map"],
    }
    (save_dir / "_final-bundle.json").write_text(json.dumps(bundle, indent=2))

    print(f"\n✅ COMPLETE — bundle at {save_dir / '_final-bundle.json'}")
    print(f"   Hero forensic blocks:      {len(inventory.get('tier_1_hero', []))}")
    print(f"   Secondary forensic blocks: {len(inventory.get('tier_2_secondary', []))}")
    print(f"   Category blocks:           {len(inventory.get('tier_3_categories', []))}")
    print(f"   Atmospheric blocks:        {len(inventory.get('atmospheric', []))}")


def main():
    if len(sys.argv) < 3:
        print("Usage: forensic_analyzer.py <video_url_or_path> <job_id>")
        sys.exit(1)
    video = sys.argv[1]
    job_id = sys.argv[2]
    if not video.startswith(("http://", "https://", "file://")):
        video = f"file://{Path(video).resolve()}"
    asyncio.run(analyze_video(video, job_id))


if __name__ == "__main__":
    main()
```

Make executable + install client:
```bash
chmod +x /data/ai/01-workspace/nemotron-forensic/forensic_analyzer.py
pip install --user openai --break-system-packages
python3 -c "from openai import AsyncOpenAI; print('✅ openai client ready')"
```

Companion `quick_describe.py` for non-forensic single-pass description (agent use, no reasoning, fast):

```python
#!/usr/bin/env python3
"""Single-pass image/video description for agent/general use."""
import sys, asyncio
from openai import AsyncOpenAI

client = AsyncOpenAI(base_url="http://localhost:8000/v1", api_key="not-needed")
MODEL = "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning"

async def describe(url: str, prompt: str = "Describe this in detail."):
    is_video = url.lower().endswith((".mp4", ".mov", ".avi", ".mkv"))
    ctype = "video_url" if is_video else "image_url"
    response = await client.chat.completions.create(
        model=MODEL,
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": prompt},
                {"type": ctype, ctype: {"url": url}}
            ]
        }],
        max_tokens=1500,
        temperature=0.2,
    )
    print(response.choices[0].message.content)

if __name__ == "__main__":
    url = sys.argv[1]
    prompt = sys.argv[2] if len(sys.argv) > 2 else "Describe this in detail."
    if not url.startswith(("http://", "https://", "file://")):
        from pathlib import Path
        url = f"file://{Path(url).resolve()}"
    asyncio.run(describe(url, prompt))
```

### ✅ Gate 1.6 — Forensic analyzer in place
Both scripts present, `forensic_analyzer.py` executable, OpenAI client installed.

---

## Step 1.7 — Mode-switch scripts

### forensic-mode.sh (NEW in v1.5)

`/data/ai/01-workspace/scripts/forensic-mode.sh`:

```bash
#!/bin/bash
# forensic-mode.sh — Start vLLM Nemotron in forensic config (high VRAM, 180K context)
# Use case: about to run a client video analysis job (T1)
set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

VLLM_COMPOSE="/data/ai/06-configs/vllm-nemotron"
VLLM_URL="http://localhost:8000/v1/models"

echo -e "${YELLOW}🔬 FORENSIC MODE — Starting Nemotron with full multimodal config...${NC}"

sudo nvidia-smi -pl 450 > /dev/null 2>&1 || true

if docker ps --format '{{.Names}}' | grep -qE "comfyui|creative-stack"; then
  echo -e "${YELLOW}⚠️  Creative stack containers running — will conflict with Nemotron VRAM.${NC}"
  read -p "   Stop them now? (y/N): " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    docker stop $(docker ps --format '{{.Names}}' | grep -E "comfyui|creative-stack") || true
    sleep 5
  else
    echo "Aborted." && exit 1
  fi
fi

if docker ps --format '{{.Names}}' | grep -q "vllm-nemotron"; then
  echo -e "${GREEN}✅ vLLM Nemotron already running on :8000.${NC}"
  exit 0
fi

echo "   Starting vLLM container..."
cd "$VLLM_COMPOSE"
docker compose up -d

echo "   Waiting for model to load (5-10 min on first run, 2-3 min after weights cached)..."
MAX_WAIT=900; WAITED=0
while ! curl -s "$VLLM_URL" > /dev/null 2>&1; do
  sleep 10; WAITED=$((WAITED + 10)); echo -n "."
  if [ $WAITED -ge $MAX_WAIT ]; then
    echo -e "\n${RED}❌ Timeout. docker logs vllm-nemotron${NC}" && exit 1
  fi
done

echo ""
echo -e "${GREEN}✅ NEMOTRON FORENSIC MODE READY — Port 8000${NC}"
nvidia-smi --query-gpu=memory.used,memory.free,power.draw,temperature.gpu --format=csv,noheader
echo ""
echo "Next: ./client-job.sh <video_path> <job_id>"
```

### client-job.sh (NEW in v1.5)

`/data/ai/01-workspace/scripts/client-job.sh`:

```bash
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
```

### creative-mode.sh

`/data/ai/01-workspace/scripts/creative-mode.sh`:

```bash
#!/bin/bash
# creative-mode.sh — Switch to ComfyUI creative stack
# Use case: forensic JSON bundle exists on disk, ready to run ComfyUI workflow
# Sequential: stops vllm-nemotron if running, flushes VRAM, brings up ComfyUI
set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

COMFYUI_COMPOSE="/data/ai/06-configs/comfyui"
COMFYUI_URL="http://localhost:8188"
VRAM_TARGET_GB=${1:-24}
VRAM_TARGET_MB=$((VRAM_TARGET_GB * 1024))

echo -e "${YELLOW}🎨 CREATIVE MODE — Switching to ComfyUI (target: ${VRAM_TARGET_GB}GB free)...${NC}"

if docker ps --format '{{.Names}}' | grep -q "vllm-nemotron"; then
  echo -e "${YELLOW}⚠️  vllm-nemotron running (~28-30GB VRAM). Stop to free for ComfyUI?${NC}"
  read -p "   Stop now? (y/N): " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    docker stop vllm-nemotron || true
    sleep 5
  else
    echo "Aborted." && exit 1
  fi
fi

VRAM_FREE_MB=$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits)
if [ "$VRAM_FREE_MB" -lt "$VRAM_TARGET_MB" ]; then
  echo -e "${RED}❌ Insufficient VRAM: $((VRAM_FREE_MB / 1024))GB free (need ${VRAM_TARGET_GB}GB).${NC}"
  echo "   Check: nvidia-smi · docker ps · fuser /dev/nvidia*"
  exit 1
fi

if docker ps --format '{{.Names}}' | grep -qE "comfyui|creative-stack"; then
  echo -e "${GREEN}✅ ComfyUI already running on :8188.${NC}"
  nvidia-smi --query-gpu=memory.used,memory.free,power.draw,temperature.gpu --format=csv,noheader
  exit 0
fi

echo "   Starting ComfyUI container..."
cd "$COMFYUI_COMPOSE"
docker compose up -d

echo "   Waiting for ComfyUI to be ready (30-90 sec)..."
MAX_WAIT=120; WAITED=0
while ! curl -s "$COMFYUI_URL" > /dev/null 2>&1; do
  sleep 5; WAITED=$((WAITED + 5)); echo -n "."
  if [ $WAITED -ge $MAX_WAIT ]; then
    echo -e "\n${RED}❌ Timeout. docker logs comfyui${NC}" && exit 1
  fi
done

echo ""
echo -e "${GREEN}✅ COMFYUI CREATIVE MODE READY — Port 8188${NC}"
nvidia-smi --query-gpu=memory.used,memory.free,power.draw,temperature.gpu --format=csv,noheader
echo ""
echo "Next: Load _final-bundle.json as conditioning input in ComfyUI workflow"
```

**Usage:**
- `./creative-mode.sh` — Default (24GB VRAM target, standard ComfyUI workflow)
- `./creative-mode.sh 30` — T2+ full VRAM swap (heavy creative workload)
- `./creative-mode.sh 7` — T1 exception (minimal FLUX-only workflow)

### Make all mode-switch scripts executable

```bash
chmod +x /data/ai/01-workspace/scripts/forensic-mode.sh
chmod +x /data/ai/01-workspace/scripts/client-job.sh
chmod +x /data/ai/01-workspace/scripts/creative-mode.sh
```

### ✅ Gate 1.7 — Mode scripts ready
All three scripts executable. `forensic-mode.sh` starts vLLM correctly. `client-job.sh` runs end-to-end.

---

## Step 1.8 — First real client video test

If you have a sample video (5-30 seconds is ideal for first run):

```bash
# Stage the test video
sudo mkdir -p /mnt/client-videos
sudo cp /path/to/your/sample.mp4 /mnt/client-videos/

# Run full pipeline
/data/ai/01-workspace/scripts/client-job.sh /mnt/client-videos/sample.mp4 test-001

# Inspect output
ls -la /data/ai/08-portfolio/forensic/test-001/
cat /data/ai/08-portfolio/forensic/test-001/_final-bundle.json | python3 -m json.tool | head -100
```

Expected wall-clock time for a 30-second commercial clip:
- Pass 1 (inventory): 30-60 sec
- Pass 2 parallel (e.g. 5 hero + 10 secondary + 5 categories): 3-5 min (prefix caching helps)
- Pass 3 (consistency map): 30-60 sec
- **Total: 5-7 minutes** for forensic analysis. Output JSON ~50-200 KB of structured detail.

### ✅ Gate 1.8 — Phase 1 COMPLETE
Test run produces non-trivial `_final-bundle.json` with hero/secondary/category blocks. VRAM stays under 32GB throughout. Phase 1 done ✅


---

---

# PHASE 2 — Hermes Agent + Aion UI
> **Goal:** Hermes Agent running with 3 profiles using nested fallback chains (personal, uncensored, **client** — new in v1.5). Aion UI connected from Mac.

---

## Step 2.1 — Install Hermes Agent

### 2.1.1 — Install system Node (required for hermes-workspace systemd service, v1.6.2)

> **Why apt-installed Node, not nvm:** nvm-managed Node lives under `~/.nvm/versions/node/vX.Y.Z/bin` — a path that's user-shell-specific and invisible to systemd's PATH. Symlinking the binaries works short-term but breaks silently on Node version upgrades. NodeSource's apt repo installs Node at `/usr/bin/node` and `/usr/bin/npm`, which systemd sees natively and survives upgrades. nvm remains fine for interactive development; it's just not the right tool for systemd-managed services.

```bash
# Install Node 22 LTS via NodeSource (the official upstream apt repo)
# v1.6.3: Node 22 chosen because the workspace's package.json engines field
# was satisfied by either 20 or 22, and 22 is closer to the nvm-installed v24
# the operator was previously using for interactive dev (avoids version surprise).
# Node 20 still works fine if you prefer the older LTS.
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify — both should be in /usr/bin/
which node && node --version       # /usr/bin/node, v22.x
which npm && npm --version         # /usr/bin/npm, 10.x

# Install pnpm globally via system npm (NOT nvm)
sudo npm install -g pnpm
which pnpm && pnpm --version       # /usr/bin/pnpm or /usr/local/bin/pnpm, 9.x+
```

> If `which pnpm` returns `/usr/local/bin/pnpm`, that's fine — `/usr/local/bin` is in systemd's default PATH. The failure mode this avoids is `pnpm` landing in `~/.nvm/...` where systemd can't find it.

### 2.1.2 — Install Hermes Agent

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

# Install the web dashboard CLI dependencies
pip install --break-system-packages 'hermes-agent[web]'

# v1.6.2 NEW — explicit aiohttp install
# The [web] extras don't always pull aiohttp despite the dashboard needing it
# (filed upstream: <link to Hermes issue if you opened one>)
pip install --break-system-packages aiohttp

# Verify
hermes --version
hermes dashboard --help   # should print usage, not "command not found" or "ModuleNotFoundError: aiohttp"
```

### 2.1.3 — Locate the hermes binary (v1.6.2 NEW — critical for systemd unit files)

```bash
# Hermes installs to ~/.local/bin/ when pip's user-install path is used
# (most common on Ubuntu 24 with PEP 668 managed environments)
# OR to /usr/local/bin/ when installed system-wide
HERMES_BIN=$(which hermes)
echo "Hermes binary location: $HERMES_BIN"
echo "Use this value for ExecStart= in all hermes-* systemd units"

# If empty, hermes isn't on PATH — try:
# ls -la ~/.local/bin/hermes /usr/local/bin/hermes
# Then export PATH=$PATH:~/.local/bin and re-source ~/.bashrc
```

**Save the output of `which hermes` — every systemd unit below uses it as `<HERMES_BIN>`.**

---

## Step 2.2 — Global Config

`~/.hermes/config.yaml`:

```yaml
model:
  provider: custom
  base_url: "http://localhost:8000/v1"
  api_key: "none"
  model: "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning"
  max_tokens: 4096

memory_dir: ~/.hermes/memory
skills_dir: ~/.hermes/skills

tracing:
  enabled: true
  exporter: otlp
  endpoint: "http://localhost:4317"
  service_name: "hermes-agent-mushishi"
```

Test: `hermes chat "Confirm you are Nemotron Omni running locally."`

---

## Step 2.3 — Two Profiles with Nested Fallback Chains

### personal profile
`~/.hermes/profiles/personal.yaml`:

```yaml
name: personal
description: "General work — GPU Nemotron → cloud (LiteLLM) → CPU PRISM (last resort)"
model:
  provider: custom
  base_url: "http://localhost:8000/v1"
  api_key: "none"
  model: "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning"
  max_tokens: 4096
  fallback:
    # v1.6.4 Option B: cloud via LiteLLM before CPU (CPU is last resort)
    provider: custom
    endpoint: "http://localhost:4000/v1"
    model: "cloud-fallback"
    trigger: connection_error
    fallback:
      # Last resort: CPU PRISM (always-on, sovereignty floor — never cloud)
      provider: custom
      base_url: "http://localhost:8001/v1"
      api_key: "none"
      model: "nemotron-cpu-prism"
      trigger: connection_error
      fallback: null   # STOP — CPU is the floor, nowhere else to go
```

### uncensored profile
`~/.hermes/profiles/uncensored.yaml`:

```yaml
name: uncensored
description: "Privacy/uncensored work — GPU Nemotron → CPU PRISM → STOP. Never cloud."
model:
  provider: custom
  base_url: "http://localhost:8000/v1"
  api_key: "none"
  model: "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning"
  max_tokens: 4096
  fallback:
    provider: custom
    base_url: "http://localhost:8001/v1"
    api_key: "none"
    model: "nemotron-cpu-prism"
    trigger: connection_error
    fallback: null   # STOP — never reach cloud
privacy_mode: true
```

### client profile (NEW in v1.5 — T1 forensic creative work)

`~/.hermes/profiles/client.yaml`:

```yaml
name: client
description: "Forensic creative work — vLLM Nemotron only. Never falls back. Local only."
model:
  provider: custom
  base_url: "http://localhost:8000/v1"
  api_key: "none"
  model: "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning"
  max_tokens: 8192
  fallback: null   # T1: client work NEVER falls back
privacy_mode: true
extra_body:
  chat_template_kwargs:
    enable_thinking: true
  reasoning_budget: 16384
```

> **Why no fallback for client profile:** A CPU GGUF fallback or cloud call would silently produce a different-quality forensic description. The whole point of the forensic pipeline is consistency between what Nemotron describes and what the creative stack regenerates. Degrading silently breaks that contract.

```bash
hermes profile default personal
hermes profile list
```

> **Note on uncensored queue behavior:** When both GPU and CPU Nemotron are unreachable, Hermes Agent with `fallback: null` will refuse the task and return an error message. This is intentional. It is **not** a silent queue with auto-retry. You must manually restart inference and re-submit. The creative-mode.sh script now warns you when CPU Nemotron is also down so you know before starting creative work.

---

### 2.3.1 — Hermes .env precedence model (v1.6.2 NEW — read carefully)

Hermes loads environment variables from multiple `.env` files, and **profile-level `.env` files override the main `.env` with `override=True`**. This silently overrode the API key during our Phase 2.5 execution and cost ~hours of debugging. Document, don't fight it.

#### Load order (later overrides earlier)

1. Process environment (systemd `Environment=` lines)
2. `EnvironmentFile=` paths in the systemd unit, in order listed
3. `~/.hermes/.env` (main env — global keys, default settings)
4. `~/.hermes/profiles/<profile-name>/.env` (per-profile overrides — **wins over main .env**)
5. CLI flags (`--port`, `--host` etc. — override everything else)

#### Which file should hold what

| Variable | Canonical location | Why |
|---|---|---|
| `GROQ_API_KEY`, `OPENROUTER_API_KEY`, `NGC_API_KEY` | `~/.hermes/.env` (main) | Global creds, used by all profiles |
| `API_SERVER_ENABLED`, `API_SERVER_HOST`, `API_SERVER_PORT` | `~/.hermes/.env` (main) | Process-level, not profile-level |
| `API_SERVER_KEY` | `~/.hermes/profiles/personal/.env` (profile) | Profile-scoped auth boundary — `client` profile can have a different key from `personal` |
| `API_SERVER_CORS_ORIGINS` | `~/.hermes/profiles/personal/.env` (profile) | Profile-scoped — different CORS posture per profile |
| `HERMES_API_URL`, `HERMES_DASHBOARD_URL` | `~/.hermes/profiles/personal/.env` (profile) | Used by the workspace PWA, which is profile-aware |
| `HERMES_DASHBOARD_SESSION_TOKEN` | `~/.hermes/.env` (main) | **v1.7 NEW — pin this or the desktop app breaks on reboot.** Dashboard mints a fresh random token on every start; setting this env var overrides it with a stable value. The official Hermes Desktop stores this token in its Remote Gateway config — without pinning, every restart invalidates the saved token and requires re-pairing. Profile-level `.env` precedence warning applies: if `~/.hermes/profiles/personal/.env` also defines this key, it will override main `.env` (see §v1.6.2-1). |

#### Operating implications

- **When debugging "wrong API key" errors,** ALWAYS check the profile-level `.env` first. If `~/.hermes/.env` and `~/.hermes/profiles/personal/.env` both contain `API_SERVER_KEY=...`, the profile-level value wins. Pull the canonical value with:
  ```bash
  grep '^API_SERVER_KEY=' ~/.hermes/profiles/personal/.env | cut -d= -f2
  ```
- **When rotating credentials,** edit the profile-level `.env`, not the main one — unless you want to nuke creds across all profiles, in which case edit both.
- **Don't duplicate.** If a var lives in the profile-level `.env`, remove it from the main `.env` to avoid future confusion. Per Phase 2.5 execution, we cleaned up the duplicate `API_SERVER_KEY` from main `.env` and left only the profile-level one.

#### Make this less surprising in the future

Add to the comment block at the top of `~/.hermes/.env`:

```bash
# === HERMES MAIN ENV ===
# This file holds GLOBAL settings used by all profiles.
# PROFILE-LEVEL .env files at ~/.hermes/profiles/<name>/.env OVERRIDE values here.
# Per-profile auth keys, CORS settings, and URL configs live in profile .env files.
# See Step 2.3.1 of mushishi-sovereign-ai-stack-v1.6.2.md
```

And to each profile `.env`:

```bash
# === HERMES PROFILE: personal ===
# Variables here override ~/.hermes/.env
# Profile-scoped: API_SERVER_KEY, API_SERVER_CORS_ORIGINS, HERMES_*_URL
```

> **Why this section is mandatory reading:** Phase 2.5 execution found duplicate `API_SERVER_KEY` values in main and profile `.env` files, with the profile-level one (a weak guessable string) silently overriding the strong randomly-generated one in main `.env`. Without documenting this precedence model, any future debugging session that touches `.env` files will rediscover this the hard way. The discovery cost real time during execution and would cost equal time on every rebuild.

---

## Step 2.4 — Hermes as systemd Service

```bash
HERMES_BIN=$(which hermes)
[ -z "$HERMES_BIN" ] && { echo "ERROR: hermes binary not on PATH"; exit 1; }

sudo tee /etc/systemd/system/hermes-agent.service > /dev/null << EOF
[Unit]
Description=Hermes Agent (gateway)
After=network.target docker.service
[Service]
Type=simple
User=mushi
WorkingDirectory=/home/mushi
EnvironmentFile=/home/mushi/.hermes/.env
EnvironmentFile=-/home/mushi/.hermes/profiles/personal/.env
ExecStart=$HERMES_BIN gateway run
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable hermes-agent
sudo systemctl start hermes-agent
```

> Two non-obvious things in that block:
> - **Unquoted `EOF`** (not `'EOF'`) — required so `$HERMES_BIN` interpolates inside the heredoc. A quoted heredoc writes literal `$HERMES_BIN` into the unit file. Easy to miss.
> - **Second `EnvironmentFile=-` line** — the leading `-` means "load if exists, ignore if not." This makes the profile-level `.env` take effect (per Step 2.3.1) when present, without requiring it.

```bash
chmod 600 ~/.hermes/.env   # secrets file permissions
```

### Add the dashboard as a parallel systemd service (v1.6 NEW)

The dashboard is a separate process from the gateway. Per Hermes docs they "can run side by side on the same host... they are independent: starting or stopping the dashboard does not affect the gateway, and vice versa."

```bash
sudo tee /etc/systemd/system/hermes-dashboard.service > /dev/null << EOF
[Unit]
Description=Hermes Agent Dashboard (v1.7 — remote-desktop backend)
After=hermes-agent.service network-online.target tailscaled.service
Wants=hermes-agent.service network-online.target
[Service]
Type=simple
User=mushi
WorkingDirectory=/home/mushi
EnvironmentFile=/home/mushi/.hermes/.env
EnvironmentFile=-/home/mushi/.hermes/profiles/personal/.env
# v1.7: --tui is MANDATORY for official Hermes Desktop remote chat mode.
#       Without --tui, /api/status passes (app says "ready") but the chat
#       WebSocket (/api/ws + /api/pty) is refused and chat silently does nothing.
#       This is the #1 failure mode reported in the field.
# --insecure: dashboard refuses non-loopback bind without this flag. Auth is
#       provided by: UFW (tailscale0-only) + Tailscale ACLs + pinned session
#       token (HERMES_DASHBOARD_SESSION_TOKEN in EnvironmentFile above).
#       WireGuard encrypts transport. Same rationale as v1.6.2 — see Decision Log.
# Bind to tailscale IP directly (tighter than 0.0.0.0 — socket unreachable
# outside tailnet even if a UFW rule is ever misconfigured).
ExecStart=$HERMES_BIN dashboard --host $TS_IP --port 9119 --no-open --insecure --tui
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable hermes-dashboard
sudo systemctl start hermes-dashboard
sleep 3
systemctl status hermes-dashboard --no-pager | head -20
```

> **The `--insecure` flag and why it's actually fine here:** Hermes' dashboard refuses to bind to a non-loopback interface without `--insecure`, which is its way of forcing the operator to acknowledge "I know this UI has no auth — I'm relying on something else (UFW, reverse proxy) for access control." That description matches our posture exactly: UFW restricts `:9119` to the `tailscale0` interface, and Tailscale handles auth at the network layer. The flag isn't actually insecure in our deployment; it's an upstream warning gate we have to pass through. The comment in the unit file ensures future-you doesn't strip the flag thinking it's a leftover debug option.

### ✅ Gate 2.4 (v1.6)
Both services active:
- `systemctl status hermes-agent` → active, listening on `:8642`
- `systemctl status hermes-dashboard` → active, listening on `:9119`
No errors in `journalctl -u hermes-agent -n 20` or `journalctl -u hermes-dashboard -n 20`.
Quick sanity: `curl -sS http://localhost:8642/health` returns `200 OK`.

---

## Step 2.5 — Official Hermes Desktop (Remote Gateway mode) (v1.7 — replaces PWA)

> **v1.7 change rationale:** The third-party `outsourc-e/hermes-workspace` PWA has been retired. Nous Research shipped a first-party **Remote Gateway** mode in the official Hermes Desktop app — the Mac connects to mushishi's dashboard over Tailscale and runs zero local inference. This is functionally what the PWA did, but first-party, native, and Nous-maintained. The PWA approach (§v1.6-1) is superseded. See Decision Log §v1.7-1 for full reasoning.

### 2.5.1 — Prerequisites: confirm mushishi backend is remote-desktop-ready

Before installing the Mac app, confirm Gate 1.7-A has passed on mushishi:

```bash
# On mushishi — quick backend check
TS_IP=$(tailscale ip -4)
TOKEN=$(grep '^HERMES_DASHBOARD_SESSION_TOKEN=' ~/.hermes/.env | cut -d= -f2-)
curl -sS -H "X-Hermes-Session-Token: $TOKEN" "http://$TS_IP:9119/api/status" | python3 -m json.tool | head -5
curl -sS -o /dev/null -w "%{http_code}" -H "X-Hermes-Session-Token: $TOKEN" "http://$TS_IP:9119/api/ws"
echo " ← /api/ws (expect 200 or 400/426)"
systemctl is-active hermes-agent && echo "✅ gateway active"
```

All must pass before continuing. If not, re-run the OP 5–7 sequence from the v1.7 migration patch.

### 2.5.2 — Pin the session token (if not already done)

The dashboard session token must be stable across reboots — the Mac app stores it and it must match on every connect.

```bash
# On mushishi — generate token if not already pinned:
TOKEN=$(openssl rand -base64 32)
echo "Save to Bitwarden: HERMES_DASHBOARD_SESSION_TOKEN = $TOKEN"
echo "" >> ~/.hermes/.env
echo "HERMES_DASHBOARD_SESSION_TOKEN=$TOKEN" >> ~/.hermes/.env
chmod 600 ~/.hermes/.env
sudo systemctl restart hermes-dashboard
```

> If you already ran the v1.7 migration patch (OPs 3–4), the token is already pinned — skip this step. The Bitwarden entry is the source of truth.

### 2.5.3 — Install the official Hermes Desktop on Mac (Reddy)

**Remove the old PWA first:**
- Quit the Hermes Workspace PWA.
- In Brave/Chrome: `brave://apps` or `chrome://apps` → right-click Hermes Workspace → Remove.
- Remove from Mac Dock if present.

**Install the official desktop:**
1. Download the macOS `.dmg` from the Nous releases page (signed + notarized): `https://github.com/NousResearch/hermes-agent/releases/latest`
2. Install and launch. On first launch it will offer to set up a **local** backend — **do not complete local onboarding**. Go straight to Settings → Gateway → Remote gateway.

### 2.5.4 — Configure Remote Gateway on Mac (Reddy)

Settings → Gateway → **Remote gateway**:
- **Remote URL:** `http://mushishi:9119` (or `http://<MUSHISHI_TS_IP>:9119` if MagicDNS isn't on)
- **Session token:** paste the `HERMES_DASHBOARD_SESSION_TOKEN` from Bitwarden (set in 2.5.2 / migration OP 3)
- Click **Test remote** → expect "reachable, token accepted."
- Click **Save and reconnect** → shell switches onto the mushishi backend.

**Alternative — env-var launch (pre-configures without the GUI):**
```bash
export HERMES_DESKTOP_REMOTE_URL="http://mushishi:9119"
export HERMES_DESKTOP_REMOTE_TOKEN="<TOKEN>"   # from Bitwarden
# then launch the app; Settings shows an "env override" badge
```

> The Mac app holds only the URL + token. No model keys, no `~/.hermes` agent, no inference. The Mac is a remote control surface only.

### ✅ Gate 2.5 (v1.7)

**Service-level:**
- [ ] `systemctl is-active hermes-agent` → active
- [ ] `systemctl is-active hermes-dashboard` → active
- [ ] `systemctl is-active hermes-workspace` → **absent** (correctly retired)

**Functional (the actual cockpit test — from Mac):**
- [ ] PWA fully removed from Mac (no Dock icon, not in `brave://apps`)
- [ ] Official desktop app installed from the Nous `.dmg`
- [ ] Remote Gateway "Test remote" passed; token accepted
- [ ] **Profiles pane** → all three profiles visible: `personal`, `uncensored`, `client`
- [ ] **Chat** → send: `Confirm you are Nemotron Omni running locally via Hermes Agent on mushishi.` → response mentions Nemotron / local inference (proves `--tui` / chat WS is working)
- [ ] Mac RAM stays under 13 GB (app is a thin shell; no local agent)
- [ ] `hermes-agent.service` was never restarted during the whole patch (gateway uptime continuous)

When all check, Phase 2 complete. Proceed to Phase 3.

### Step 2.6 (DEFERRED — optional) — Aion UI as secondary cockpit
Only execute if you specifically need Aion's file-tree / 9-format preview / drag-drop features. Aion is not required for Phase 2 or any subsequent phase. If pursued, configure Aion's "Custom" provider to point at `http://mushishi:8642/v1` with the same `API_SERVER_KEY`, and select Hermes Agent (not Gemini CLI) as the agent runtime to avoid the `CLI not found in PATH` failure mode.

---

## Phase 2.5 Lessons Learned (v1.6.3 NEW)

The Hermes Workspace setup was supposed to take 30 minutes per the v1.6.2 spec. Actual execution took ~5 hours across May 21, 2026 due to a cascade of environmental gotchas and one genuinely subtle bug. Captured here for institutional memory:

### Time breakdown

| Stage | Spec'd | Actual | Cause of overage |
|---|---|---|---|
| Hermes install + systemd | 30 min | 90 min | Binary path detection, missing aiohttp, nvm-vs-system-Node, dashboard `--insecure` requirement, profile-level `.env` override |
| Workspace install + systemd | 20 min | 90 min | Node migration, ExecStart pattern divergence, password rotation cascade |
| PWA login final gate | 5 min | 90 min | `COOKIE_SECURE=0` bug (browsers drop Secure cookies over HTTP) |
| Documentation patches | (not spec'd) | 60 min | Three patch rounds (v1.6, v1.6.1, v1.6.2, v1.6.3) |
| **Total** | **55 min** | **~5h 30min** | 6x overrun |

### Why the overrun was OK

1. Each gotcha is now documented — future Phase 2 takes 30 min as originally spec'd.
2. The patch process tightened: every discovered issue became a documented fix + decision log entry, not tribal knowledge.
3. The dual-Claude-Code workflow proved itself on the hardest bug of the phase.
4. Three different "this looked right but was actually wrong" failure modes got captured — these are the most valuable lessons because they're hardest to anticipate.

### The three "looked right but was wrong" failures

**1. `systemctl is-active` was green when login was broken.** The gate test was too shallow — it checked process liveness, not user-facing functionality. Every gate test from Phase 3 onwards should test the user-facing invariant, not just "the daemon started." Patch 1.6.3-B encodes this for Gate 2.5; apply the same pattern going forward.

**2. The API key in `.env` looked correct but was being overridden silently.** Profile-level `.env` overrode main `.env` with `override=True`. This is documented in v1.6.2 Patch G as "Step 2.3.1 — Hermes .env precedence model." The lesson: when something's silently wrong, check ALL config sources, not just the obvious one.

**3. The login error said "Internal Server Error" but actually it was a cookie problem.** The error message lied — the server's response was fine, but the browser dropped the cookie and the *subsequent* page render threw 500 because it expected an authenticated state that didn't exist. Lesson for debugging future auth issues: **inspect the full HTTP transaction including cookies and headers, not just the status code and body.**

### Process improvements going forward

1. **Every phase has a "real" gate test, not just a "service is up" gate.** See Patch 1.6.3-B for the pattern.
2. **Every credential change has a propagation script.** See Patch 1.6.3-H. Single point of update, validates the full chain.
3. **Dual Claude Code workflow is the default for any client-server bug.** See Patch 1.6.3-I.
4. **Patches get written within 24h of execution.** v1.6 → v1.6.1 → v1.6.2 → v1.6.3 in one week is fine; v1.6 sitting in chat history for 6 weeks waiting to be applied is not.

---

# PHASE 3 — Kimi K2.6 + Groq + OpenRouter via LiteLLM (Option B) + Hermes Wiring + Fallback Test
> **Status:** ✅ COMPLETE (May 22, 2026, v1.6.4)
> **Goal:** LiteLLM active as Docker service on :4000 with Postgres budget persistence (prerequisite). Personal profile cloud tier routes through LiteLLM (Kimi→Groq→OpenRouter with per-provider caps). Hermes sovereignty boundaries enforced — uncensored/client never reach cloud. Full tiered fallback chain tested including tcpdump sovereignty verification.
>
> **v1.6.4 order of operations:** LiteLLM (Phase 5.1, now promoted) is an active prerequisite — complete it before Step 3.3. See revised Phase 5.1 status above. Option B routing: personal fallback is GPU→cloud→CPU (CPU now last resort, not second tier).

---

## Step 3.0 — Get NVIDIA NGC API Key (if not already acquired)

If you obtained an NGC key during a prior NIM attempt (v1.3/v1.4 plan), skip to 3.1.

Otherwise:
1. Go to **https://build.nvidia.com/moonshotai/kimi-k2.6** (or any model page on build.nvidia.com)
2. Click "Get API Key" — free NVIDIA developer account, no credit card
3. Save the key (format: `nvapi-XXXXXXXXXXXX`) in your password manager
4. Store it where you can reach it later:

```bash
mkdir -p /data/ai/06-configs/nvidia-api
echo "NGC_API_KEY=nvapi-your_key_here" > /data/ai/06-configs/nvidia-api/.env
chmod 600 /data/ai/06-configs/nvidia-api/.env
```

This key is the credential for both Kimi K2.6 (cloud multimodal fallback) and — should you ever revisit it — the NIM container path.

### ✅ Gate 3.0
NGC key acquired and stored at `chmod 600` permission. Key value confirmed by Steps 3.1.

---

## Step 3.1 — Verify Kimi K2.6 Access (free — uses NGC key)

Your NGC API key (from Step 3.0, or from a prior NIM setup) grants Kimi K2.6 access. The key works the same regardless of how you obtained it. Test it:

```bash
# v1.5 location:
export NGC_API_KEY=$(grep NGC_API_KEY /data/ai/06-configs/nvidia-api/.env | cut -d= -f2)
# Legacy NIM location (if you had a prior setup):
# export NGC_API_KEY=$(grep NGC_API_KEY /data/ai/06-configs/nemotron/.env | cut -d= -f2)

curl https://integrate.api.nvidia.com/v1/chat/completions \
  -H "Authorization: Bearer $NGC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"moonshotai/kimi-k2.6","messages":[{"role":"user","content":"Which model are you?"}],"max_tokens":50}'
```

> **Why Kimi K2.6 before Groq:** Kimi K2.6 is multimodal (image, video, text, reasoning). When GPU Nemotron is offline and an agent needs to process an image or video frame, Groq (text-only) can't help. Kimi K2.6 can. For pure text tasks they're comparable; for multimodal tasks Kimi is the only free option in the chain.

### ✅ Gate 3.1
Kimi K2.6 returns a valid response using your existing NGC key.

---

## Step 3.2 — Create Groq + OpenRouter Accounts

**Groq:** https://console.groq.com → API Keys → Create → name `mushishi-groq-fallback`
Key format: `gsk_...` | Free tier: 14,400 requests/day on Llama 3.3 70B

**OpenRouter:** https://openrouter.ai → API Keys → Create → name `mushishi-openrouter-backstop`
Add $10 credit | Key format: `sk-or-v1-...`

> **Groq daily limit:** 14,400 req/day sounds like a lot, but heavy DeerFlow multi-step research sessions can burn hundreds of requests. Check usage weekly at https://console.groq.com/settings/usage when DeerFlow is active.

---

## Step 3.3 — Add Keys to Hermes Environment

```bash
nano ~/.hermes/.env
```

### Main `.env` — global, process-level settings only

```bash
NGC_API_KEY=nvapi-your_key_here
GROQ_API_KEY=gsk_your_key_here
OPENROUTER_API_KEY=sk-or-v1_your_key_here

# v1.6 — Hermes API server process-level config (not profile-scoped)
API_SERVER_ENABLED=true
API_SERVER_HOST=0.0.0.0
API_SERVER_PORT=8642

# NOTE: API_SERVER_KEY, API_SERVER_CORS_ORIGINS, and HERMES_*_URL live in
# the profile-level .env at ~/.hermes/profiles/personal/.env — see Step 2.3.1
# for the precedence model and why these are profile-scoped.
```

### Profile `.env` — `~/.hermes/profiles/personal/.env`

```bash
# === HERMES PROFILE: personal ===
# Variables here OVERRIDE main ~/.hermes/.env

# v1.6 — API server profile-scoped settings
API_SERVER_KEY=<generate with: openssl rand -hex 32>
API_SERVER_CORS_ORIGINS=http://<MUSHISHI_TS_IP>:9119

# v1.6 — Workspace + Dashboard URLs (used by the workspace PWA on Mac)
HERMES_API_URL=http://<MUSHISHI_TS_IP>:8642
HERMES_DASHBOARD_URL=http://<MUSHISHI_TS_IP>:9119

# v1.6.4 — LiteLLM master key (profile-scoped auth — same precedence as API_SERVER_KEY above)
# Hermes uses this to authenticate to LiteLLM :4000. Profile-scoped because only personal
# profile routes through LiteLLM; uncensored/client must not.
LITELLM_MASTER_KEY=sk-<generate with: openssl rand -hex 32>
```

Both files: `chmod 600`.

> **v1.6.4 schema note (Patch D1):** The personal profile's `cloud-fallback` provider must use `provider: custom` (not `provider: openai_compatible`) for any OpenAI-compatible upstream in a Hermes profile YAML. Also add `model: cloud-fallback` to the entry. Confirmed during execution.

> **NGC key:** Copy from `/data/ai/06-configs/nemotron/.env` — same key, no new signup.

```bash
chmod 600 ~/.hermes/.env
chmod 600 ~/.hermes/profiles/personal/.env
sudo systemctl restart hermes-agent
```

---

## Step 3.4 — Test Full Fallback Chain

```bash
# Test 1: Kimi K2.6 kicks in when GPU + CPU Nemotron offline
docker stop vllm-nemotron
# (assuming Phase 4.5 CPU Nemotron not installed yet — if it is, stop that too)
hermes chat --profile personal "Which model are you? Where are you running?"
# Expected: Kimi K2.6 response from NVIDIA API

# Test 2: Uncensored refuses cloud
hermes chat --profile uncensored "test"
# Expected: error/refusal, not a cloud response

# Test 3 (v1.5 NEW): Client profile refuses ANY fallback
hermes chat --profile client "test"
# Expected: error/refusal (vLLM is down)

# Restore
forensic-mode.sh   # or agent-mode.sh for lighter config
```

### ✅ Gate 3.4
Personal profile routes: CPU Nemotron (if installed) → Kimi K2.6 → Groq when GPU offline. Uncensored never reaches cloud. Phase 3 complete ✅

> **v1.6.4 validation note:** Test 3 (personal + cloud exhausted → CPU PRISM) was initially run before the `-a nemotron-cpu-prism` alias fix (Patch 1.6.4-B2) was applied. With the wrong alias, the CPU model registered under its filename and the personal profile's priority-3 reference didn't resolve. **Re-run Test 3 after applying the alias fix** to confirm personal correctly falls to CPU PRISM as last resort. Gate 3.4 is not closed until Test 3 passes with the corrected alias.

---

---

# PHASE 4 — Observability + VS Code + Benchmark + Backups + Travel Test
> **Goal:** Full monitoring stack live. Benchmark baseline established. Backup automation running. VS Code remote editing working. Tailscale verified off-network.

---

## Step 4.1 — Netdata (Live System Monitoring)

```bash
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --non-interactive
```

Verify GPU plugin:
```bash
curl -s http://localhost:19999/api/v1/charts | python3 -m json.tool | grep nvidia
```

If empty: `sudo /etc/netdata/edit-config charts.d.conf` → uncomment `nvidia=yes` → `sudo systemctl restart netdata`

Open from Mac: `netdata` alias → `http://mushishi:19999`

### ✅ Gate 4.1
Netdata dashboard loads from Mac. GPU VRAM chart updates live.

---

## Step 4.2 — Arize Phoenix (LLM Tracing)

`/data/ai/06-configs/phoenix/docker-compose.yml`:

```yaml
services:
  phoenix:
    image: arizephoenix/phoenix:latest
    container_name: arize-phoenix
    restart: unless-stopped
    ports:
      - "6006:6006"
      - "4317:4317"
      - "4318:4318"
    volumes:
      - phoenix_data:/root/.phoenix
    environment:
      - PHOENIX_WORKING_DIR=/root/.phoenix
volumes:
  phoenix_data:
```

```bash
cd /data/ai/06-configs/phoenix && docker compose up -d
```

Open from Mac: `phoenix` alias → `http://mushishi:6006`

**What to watch for in Phoenix:**
- Latency spikes > 5s on Nemotron = KV cache pressure
- Fallback events = Nemotron was offline (visible in trace metadata)
- Token counts growing across sessions = clear Hermes memory periodically
- Tool call failures = Hermes skill misconfiguration

**Phoenix fallback frequency check (weekly cron):**
```bash
# Add to crontab: crontab -e
# 0 9 * * 1 curl -s http://localhost:6006/api/traces | python3 /data/ai/01-workspace/scripts/check-fallback-rate.py >> /data/ai/04-logs/phoenix-alerts.log 2>&1
# (Script: count traces where provider != nemotron, alert if >10% of last hour's traces)
```

### ✅ Gate 4.2
Phoenix UI loads from Mac. After sending a Hermes task, full trace appears with latency breakdown.

---

## Step 4.3 — Benchmark Script (Performance Regression Detection)

```bash
nano /data/ai/01-workspace/scripts/benchmark.sh
```

```bash
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

  GPU_INFO=$(nvidia-smi --query-gpu=power.draw,temperature.gpu,clocks.throttle_reasons --format=csv,noheader,nounits)
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
```

```bash
chmod +x /data/ai/01-workspace/scripts/benchmark.sh

# Run baseline now (establishes first data point)
benchmark.sh

# Monthly cron
(crontab -l 2>/dev/null; echo "0 9 1 * * /data/ai/01-workspace/scripts/benchmark.sh >> /data/ai/04-logs/benchmark-cron.log 2>&1") | crontab -
```

### ✅ Gate 4.3
Benchmark completes 4 tests, reports tok/s, logs to CSV. This is your baseline.

---

## Step 4.4 — Backup Strategy

```bash
sudo apt install restic -y
```

`/data/ai/01-workspace/scripts/backup.sh`:

```bash
#!/bin/bash
# backup.sh — Incremental encrypted backup to external NVMe
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

BACKUP_REPO="/media/mushi/52B434D9B434C171/ai-backup-restic"
PASS_FILE="/home/mushi/.restic-password"

if [ ! -f "$PASS_FILE" ]; then
  echo -e "${YELLOW}First run — initializing restic repo.${NC}"
  read -sp "Enter backup encryption password (save this!): " PASS
  echo "$PASS" > "$PASS_FILE"; chmod 600 "$PASS_FILE"
  restic -r "$BACKUP_REPO" init --password-file "$PASS_FILE"
fi

echo -e "${YELLOW}📦 Backup starting...${NC}"
restic -r "$BACKUP_REPO" --password-file "$PASS_FILE" backup \
  ~/.hermes/memory ~/.hermes/skills ~/.hermes/config.yaml ~/.hermes/profiles \
  /data/ai/01-workspace/comfyui/user \
  /data/ai/01-workspace/scripts \
  /data/ai/06-configs \
  /data/ai/08-portfolio/outputs \
  --exclude /data/ai/02-models \
  --exclude /data/ai/07-cache \
  --tag "$(date +%Y-%m-%d)"

# Prune: keep 7 daily, 4 weekly, 3 monthly
restic -r "$BACKUP_REPO" --password-file "$PASS_FILE" \
  forget --keep-daily 7 --keep-weekly 4 --keep-monthly 3 --prune

echo -e "${GREEN}✅ Backup complete.${NC}"
restic -r "$BACKUP_REPO" --password-file "$PASS_FILE" snapshots | tail -5
```

```bash
chmod +x /data/ai/01-workspace/scripts/backup.sh
chmod 600 /home/mushi/.restic-password   # created by script on first run

# Run first backup
backup.sh

# Weekly cron (Sunday 3am)
(crontab -l 2>/dev/null; echo "0 3 * * 0 /data/ai/01-workspace/scripts/backup.sh >> /data/ai/04-logs/backup.log 2>&1") | crontab -

# Monthly integrity check
(crontab -l 2>/dev/null; echo "0 4 1 * * restic -r /media/mushi/52B434D9B434C171/ai-backup-restic check --read-data-subset=10% --password-file /home/mushi/.restic-password >> /data/ai/04-logs/backup.log 2>&1") | crontab -
```

> ⚠️ **Backup locality risk:** Your current backup target is another NVMe on the same machine. A PSU failure or fire takes both drives. This is your **local tier**. Phase 6 adds a **remote tier** (Restic to VPS over Tailscale) for true 3-2-1 compliance. `~/.hermes/memory` and `~/.hermes/skills` are irreplaceable learned state — they're the highest priority for remote backup when VPS is ready.

### ✅ Gate 4.4
`backup.sh` completes. `restic snapshots` shows ≥1 snapshot. Monthly `restic check` cron installed.

---

## Step 4.5a — VS Code Remote-SSH

Download VS Code Intel Mac from https://code.visualstudio.com/Download.

```bash
code --version   # if command not found: Cmd+Shift+P → "Install 'code' in PATH"
```

Extensions → install **Remote - SSH** (Microsoft).

`~/.ssh/config` (Mac):
```
Host mushishi
    HostName mushishi
    User mushi
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

VS Code → green icon bottom-left → Connect to Host → mushishi.

### ✅ Gate 4.5a
VS Code opens `/data/ai/` on mushishi. Editing `agent-mode.sh` writes directly to Linux.

---

## Step 4.5b — Travel Test

Switch Mac to phone hotspot or different network. Run:
```bash
beast-status && nemotron-test && netdata && phoenix
```

### ✅ Gate 4.5b
All four work on cellular. Phase 4 complete ✅

> **v1.6.4 travel test result (May 22, 2026):** On a 2013 MacBook Pro running Sonoma via OCLP, on mobile hotspot, Tailscale held a **direct peer path through a lid-close cycle — no DERP relay fallback observed.** This is the best-case outcome (DERP relay would add latency). SSH, gateway :8642, and the workspace PWA all recovered automatically after lid-open. Travel posture confirmed solid for this hardware/network combination. Note: results may differ on restrictive networks (corporate firewalls, CGNAT) where DERP fallback is more likely — re-test if you travel to such an environment.

---

---

# PHASE 4.5 — CPU Nemotron (Always-On Sovereignty Floor)
> **Goal:** Nemotron running on CPU+RAM (port 8001) 24/7 via systemd. Uncensored profile never queues. Creative mode doesn't interrupt local inference.
> **Trigger to execute:** Creative mode running >1x/week, OR you hit the uncensored queue/wait more than twice.

---

## Step 4.5.1 — Build llama.cpp with AVX-512

```bash
mkdir -p /data/ai/01-workspace/llama.cpp
cd /data/ai/01-workspace/llama.cpp
git clone https://github.com/ggerganov/llama.cpp . 2>/dev/null || git pull
mkdir -p build && cd build

cmake .. \
  -DLLAMA_AVX2=ON \
  -DLLAMA_AVX512=ON \
  -DLLAMA_AVX512_VNNI=ON \
  -DLLAMA_NATIVE=ON \
  -DLLAMA_CUDA=OFF \
  -DCMAKE_BUILD_TYPE=Release

make -j$(nproc)
./bin/llama-server --version
```

> Ryzen 9 9900X3D supports AVX-512 and AVX-512 VNNI — both flags active.

### ✅ Gate 4.5.1
`./bin/llama-server --version` prints version.

---

## Step 4.5.2 — Download GGUF Model

```bash
mkdir -p /data/ai/02-models/nemotron-cpu
```

```bash
# v1.6.4 — PRISM-abliterated variant of the same NVIDIA base model
huggingface-cli download \
  Ex0bit/Elbaz-NVIDIA-Nemotron-3-Nano-30B-A3B-PRISM \
  Elbaz-NVIDIA-Nemotron-3-Nano-30B-A3B-PRISM-IQ4_XS.gguf \
  --local-dir /data/ai/02-models/nemotron-cpu/

ls -lh /data/ai/02-models/nemotron-cpu/*.gguf   # should show ~19GB file (MoE: 30B total, 3B active params)
```

> PRISM (Projected Direction Isolation, SNR layer selection, dual-component modification, norm-preserving orthogonalization) is a higher-quality abliteration method with credible capability-preservation claims. Stock Nemotron's trained refusals undermine the uncensored profile's purpose. See §v1.6.4-1.

### ✅ Gate 4.5.2
GGUF file present at `/data/ai/02-models/nemotron-cpu/`, non-zero size (~19GB).

---

## Step 4.5.3 — systemd Service for CPU Nemotron

```bash
sudo tee /etc/systemd/system/nemotron-cpu.service > /dev/null << 'EOF'
[Unit]
Description=Nemotron CPU Inference PRISM (llama.cpp, always-on sovereignty floor)
After=network.target

[Service]
Type=simple
User=mushi
Environment=LLAMA_BIN=/data/ai/01-workspace/llama.cpp/build-cpu/bin/llama-server
Environment=MODEL_PATH=/data/ai/02-models/nemotron-cpu/Elbaz-NVIDIA-Nemotron-3-Nano-30B-A3B-PRISM-IQ4_XS.gguf
WorkingDirectory=/data/ai/01-workspace/llama.cpp/build-cpu
ExecStart=$LLAMA_BIN \
    -m $MODEL_PATH \
    --host 0.0.0.0 \
    --port 8001 \
    --ctx-size 32768 \
    --threads 32 \
    --threads-batch 32 \
    --mlock \
    --n-gpu-layers 0 \
    --api-key "" \
    -a nemotron-cpu-prism
LimitMEMLOCK=infinity
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nemotron-cpu
sudo systemctl start nemotron-cpu
```

Watch it load (~2-5 min for 60GB model):
```bash
journalctl -u nemotron-cpu -f
```

Wait for: `llama server listening at http://0.0.0.0:8001`

### ✅ Gate 4.5.3
```bash
curl -s http://localhost:8001/v1/models | python3 -m json.tool
nemotron-cpu-test   # from Mac
```
Both return model JSON.

---

## Step 4.5.4 — Verify Fallback Chain

With GPU Nemotron stopped:
```bash
docker stop vllm-nemotron
hermes chat --profile uncensored "Confirm: which model and where (GPU or CPU)?"
```

Expected: Response at 10-20 tok/s from CPU Nemotron. Never from cloud. Never refused.

```bash
forensic-mode.sh   # restore GPU Nemotron (or agent-mode.sh for lighter config)
```

### ✅ Gate 4.5.4
Uncensored profile seamlessly routes to CPU when GPU is offline. Phase 4.5 complete ✅

---

---

### ⏳ Pending operator actions (require sudo or browser — not CC-doable)

As of v1.6.4, three items await the operator:

1. **UFW firewall rules** — run `/data/ai/01-workspace/scripts/harden-firewall.sh` with sudo. All rules (including corrected :2026 for DeerFlow, :4000 for LiteLLM) are in the script. Until this runs, :19999 (Netdata) and :6006 (Phoenix) aren't reachable from Mac over tailscale0.

2. **DeerFlow first-boot** — visit `http://mushishi:2026/setup` to create the admin account.

3. **Mac verification (post-UFW)** — once UFW allows :19999 and :6006 on tailscale0, confirm Netdata and Phoenix load from the Mac browser. (Mac-CC already verified these locally; this confirms the tailnet path.)

These don't block Phase 6 planning but should close out before declaring Phase 4 fully done from the Mac side.

---

# PHASE 5 — DeerFlow + Antigravity + LiteLLM Config
> **Status:** PARTIAL (v1.6.4): DeerFlow (:2026) ✅ + Antigravity ✅ keep + LiteLLM now ACTIVE (promoted to Phase 3 prerequisite). Unsloth (5.4) reference-only. Paperclip (5.5) conditional.

---

## Step 5.1 — LiteLLM Config (Save Now, Activate Later)

Save the config now. Activate only when you have 5+ tools independently configured against multiple providers and you feel the management pain.

```bash
mkdir -p /data/ai/06-configs/litellm
```

`/data/ai/06-configs/litellm/docker-compose.yml`: *(see previous version — unchanged)*

`/data/ai/06-configs/litellm/config.yaml`: *(see previous version — unchanged)*

> **To activate:** `cd /data/ai/06-configs/litellm && docker compose up -d` then update all tool base_urls to `http://mushishi:4000/v1`. Don't activate before you feel the pain of managing configs separately.

---

## Step 5.2 — DeerFlow 2.0

```bash
cd /data/ai/01-workspace
git clone https://github.com/bytedance/deerflow.git
cd deerflow
pip install uv --break-system-packages
uv venv .venv --python 3.12 && source .venv/bin/activate
uv pip install -r requirements.txt
cd frontend && npm install -g pnpm && pnpm install && cd ..
cp .env.example .env
# Edit .env: OPENAI_API_BASE=http://localhost:8000/v1, OPENAI_API_KEY=none
```

```bash
curl -sf -m 5 http://mushishi:2026/ > /dev/null && echo "✅ DeerFlow reachable"
open http://mushishi:2026/
# First boot: visit http://mushishi:2026/setup to create the admin account
```

---

## Step 5.3 — Antigravity (Mac — RAM-gated trial)

Check RAM baseline first: `top -l 1 -s 0 | grep "PhysMem"` — need ≥4GB free.

Download Intel (x86_64) build from https://antigravity.dev.
Configure: Base URL `http://mushishi:8642` (Hermes gateway, personal profile), not direct vLLM.

**Decision gate:** If `stats` shows RAM > 13.5GB with Antigravity + Claude Desktop → use Antigravity standalone only. If consistently > 14GB → skip, VS Code Remote-SSH covers the need.

> **v1.6.4 Antigravity decision: KEEP.** 10-minute trial on the Mac completed with RAM staying under the 14GB threshold. Configured to point at Hermes gateway :8642 (personal profile). Useful enough as a secondary cockpit alongside the Hermes Workspace PWA to justify keeping installed. Not a replacement for the PWA — complementary.

---

### Stack orchestration script (v1.6.4 NEW)

Mushi-CC created `/data/ai/01-workspace/scripts/start-stack.sh` during Phase 3-5 execution. It brings up the full Docker-based stack (LiteLLM + Postgres + Phoenix + DeerFlow nginx) in dependency order with the corrected flags:
- LiteLLM with explicit `--config /app/config.yaml`
- `--env-file` for API keys
- Postgres before LiteLLM (link dependency)

There's also `harden-firewall.sh` at `/data/ai/01-workspace/scripts/` which contains all UFW rules (must be run with sudo by the operator — see Patch 1.6.4-E2 for the corrected :2026 rule).

Add both to the backup-priority file list:
```
/data/ai/01-workspace/scripts/start-stack.sh
/data/ai/01-workspace/scripts/harden-firewall.sh
```

---

## Step 5.4 — Unsloth Reference Script

```bash
mkdir -p /data/ai/01-workspace/unsloth
```

Save `starter-finetune.py` from v1.1 here. Activate in Phase 6 when you have a specific fine-tuning goal.

**Activate trigger:** You have a concrete domain-adaptation task (client persona, style, knowledge). Don't fine-tune without a specific goal.

---

---

# PHASE 5.5 — Paperclip Management Plane (T4 Coordination)
> **Goal:** Paperclip running locally as the coordination layer above Hermes, DeerFlow, and any Claude Code workflows. Multi-tier agents managed through one dashboard with budgets, audit logs, and approval gates.
> **Trigger to execute:** Running 3+ agents with distinct workloads and feeling the management overhead. Skip if Hermes alone covers your work.

---

## Why this phase exists

After Phases 0–5 you'll have multiple agents in different tiers:
- Hermes Agent — T1 uncensored / T2 personal
- DeerFlow — T2 research
- Optional: Claude Code + gstack — T3

Without Paperclip you manage each separately — separate prompts, separate cost tracking, separate logs, no unified governance. Paperclip is the org-chart layer above all of them. Critically: it's tier-agnostic — local agents stay local, Paperclip just coordinates.

---

## What it adds

- Heartbeat scheduling (agents wake on timers, not continuous polling)
- Per-agent atomic budget enforcement (no runaway spend)
- Immutable audit trails across all agent work
- Approval gates for sensitive actions
- Multi-company isolation (portfolio work, SaaS, research as separate "companies")

---

## What it does NOT do (avoiding overlap confusion)

- **Doesn't replace Hermes Agent.** Paperclip orchestrates work; Hermes does work. Paperclip without an agent connected is a dashboard displaying nothing.
- **Doesn't replace Aion UI** as your interactive cockpit. Aion UI is for live conversation with one agent. Paperclip is for managing multiple agents doing scheduled work. Both can coexist.
- **Doesn't add inference capacity.** Same VRAM ceiling applies. A Paperclip "org chart" with 20 agents is still capped at 3-5 concurrent on local Nemotron.

---

## Step 5.5.1 — Install Paperclip on mushishi

```bash
mkdir -p /data/ai/01-workspace/paperclip
cd /data/ai/01-workspace/paperclip

# Tailnet bind = only reachable via Tailscale (matches sovereignty principle)
npx paperclipai onboard --yes --bind tailnet
```

This starts the API server at `http://0.0.0.0:3100` with embedded PostgreSQL. No external accounts required.

### ✅ Gate 5.5.1
`curl -s http://localhost:3100/health` returns a healthy response.

---

## Step 5.5.2 — Firewall + Mac Alias

UFW rule was added in the v1.4 firewall script. If you ran the firewall script before this phase existed, add the rule:

```bash
sudo ufw allow in on tailscale0 to any port 3100 proto tcp comment 'Paperclip dashboard'
```

The Mac alias `paperclip` is in the v1.4 zshrc block. If you set up aliases before v1.4:
```bash
echo "alias paperclip='open http://mushishi:3100'" >> ~/.zshrc
source ~/.zshrc
```

### ✅ Gate 5.5.2
From Mac: `paperclip` alias opens dashboard at `http://mushishi:3100`.

---

## Step 5.5.3 — Connect Hermes Agent as First Adapter

Paperclip uses adapters to connect to agent runtimes. Hermes exposes an OpenAI-compatible endpoint, so we add it as a custom OpenAI adapter pointing at the Hermes Agent service.

In Paperclip dashboard:
1. Create a Company (e.g., "Research Operations")
2. Define a top-level Goal (e.g., "Track AI infrastructure trends weekly")
3. Add an Agent → Type: OpenAI-compatible
   - Base URL: `http://localhost:8642/v1` (Hermes gateway — v1.6)
   - API Key: paste the value of `API_SERVER_KEY` from `~/.hermes/.env`
   - Model: `nvidia/nemotron-3-nano-omni-30b-a3b-reasoning`
   - Profile: `personal` (T2 — fallback chain enabled)
4. Set Budget: $0/month (Hermes is local, but the personal profile *can* fall back to Groq/OpenRouter — set a cloud spend cap as safety)
5. Assign a test Task with heartbeat schedule (e.g., every 6 hours)

> **Tier hygiene:** Never connect a Hermes `uncensored` profile to Paperclip. Paperclip logs everything in its audit trail. T1 work belongs in direct Hermes chat, not in an orchestrated workflow.

### ✅ Gate 5.5.3
Test task completes on schedule. Audit log shows the run. Budget displays $0 spent (local) or small cloud spend if it fell back.

---

## Step 5.5.4 — Optional: Connect DeerFlow + Claude Code

Once Hermes is working:

**DeerFlow** (T2 research worker):
- Adapter: Custom HTTP endpoint at `http://localhost:2026`
- Role: Deep research specialist
- Budget: small cloud cap (DeerFlow can burn Groq requests fast)

**Claude Code via gstack** (T3 — only if doing portfolio/SaaS work):
- Adapter: Claude Local (`claude_local` built-in)
- Role: Engineering team (CEO, Designer, QA via gstack slash commands)
- Budget: monthly Claude API spend cap (this is real money)

---

## Step 5.5.5 — Verify Sovereignty Boundaries

Critical end-to-end check that Paperclip doesn't accidentally cross tiers:

```bash
# 1. Paperclip should only be reachable via Tailscale
curl http://<mushishi-public-ip>:3100/health   # should fail
curl http://mushishi:3100/health                # should work (via Tailscale)

# 2. Verify Paperclip's outbound calls match expected tiers
# Watch traffic for a heartbeat cycle:
sudo tcpdump -i any port not 22 and host mushishi -c 100
# Should see: localhost:8642 (Hermes gateway), localhost:8000 (Nemotron), localhost:3100 (Paperclip itself)
# Should NOT see: unexpected external IPs from any T1/T2 agents

# 3. Verify Hermes uncensored profile is NOT exposed to Paperclip
# In Paperclip dashboard, agent list should show only personal-profile adapters
```

### ✅ Gate 5.5.5
- Paperclip reachable only via Tailscale
- Outbound traffic matches tier expectations
- No uncensored-profile agents in Paperclip
- At least one heartbeat task completed with audit trail

Phase 5.5 complete ✅

---

---

# PHASE 6 — VPS: True Sovereignty + Remote Backup
> **Status:** PLANNED — ~1 month away when VPS is available.
> **Context:** You're getting a VPS for your website, SaaS hosting, and agents. We'll use it to complete the sovereignty stack. This document will be updated with exact commands when VPS specs and provider are confirmed.

---

## What Phase 6 Does

| Component | Problem It Solves |
|---|---|
| **Headscale** (self-hosted Tailscale control) | If Tailscale's coordination servers are unreachable, your mesh breaks. Headscale is the sovereignty fallback. |
| **Remote Restic backup** | Current backup is single-site (both NVMes in same machine). VPS = off-site tier for `~/.hermes/memory`, `~/.hermes/skills`, critical configs. |
| **Cloudflare DDNS + SSH fallback** | If both Tailscale and Headscale fail, DDNS gives you a last-resort direct SSH path. |
| **Phoenix fallback alerting** | Automated weekly query of Phoenix traces — notify if personal profile falls back to cloud > 10% of requests |
| **Paperclip remote access** (if Phase 5.5 in use) | Optionally proxy Paperclip dashboard through VPS for phone access without exposing tailnet |

---

## Step 6.1 — Headscale Self-Hosted Control Server

> Full step-by-step after VPS is provisioned. Key facts to plan around:

**VPS requirements:** 1 vCPU, 1GB RAM, 20GB disk. Ubuntu 24.04. Providers: Hetzner CX11 (€3.49/mo), Contabo, OVH.

> **Not Oracle Cloud Free Tier** — Oracle's ToS grants them broad data access rights. Against sovereignty principles.

**Domain:** You'll need a subdomain pointing to the VPS (e.g., `headscale.yourdomain.com`). Caddy handles automatic HTTPS.

**Migration path:** Both mushishi and Mac switch from official Tailscale coordination to your Headscale instance with `tailscale up --login-server https://headscale.yourdomain.com`. Official Tailscale app/client still used — only the coordination server changes.

**Fallback strategy:**
```
Primary control: Official Tailscale (current)
    ↓ if unreachable
Backup control: Headscale on VPS
    ↓ if VPS also unreachable
Cloudflare DDNS: direct SSH to mushishi's public IP
```

> Headscale config, client migration commands, and Caddy setup will be detailed when VPS is ready. Kimi's full Headscale draft (from the review session) is the implementation reference.

---

## Step 6.2 — Remote Restic Backup (VPS as Off-Site Tier)

After VPS is up and has Tailscale/Headscale access:

```bash
# On VPS: install restic server
apt install restic -y
mkdir -p /backup/mushishi-remote
restic -r /backup/mushishi-remote init --password-file /root/.restic-password

# On mushishi: add remote backup to backup.sh
# Remote repo: sftp:mushi@vps-tailscale-ip:/backup/mushishi-remote

# Priority files for remote backup (irreplaceable):
# ~/.hermes/memory  — agent learned state
# ~/.hermes/skills  — acquired capabilities
# /data/ai/08-portfolio/specs/ — SDD audit trail
# /data/ai/01-workspace/paperclip/data/ — Paperclip company state (if Phase 5.5 in use)
```

Update `backup.sh` to run restic against both repos (local + remote) sequentially. Local is fast. Remote is safety.

---

## Step 6.3 — Cloudflare DDNS Fallback SSH

```bash
# On mushishi: install ddclient for Cloudflare DDNS
sudo apt install ddclient -y
# Configure with your Cloudflare API token + domain
# mushishi-ssh.yourdomain.com → mushishi's dynamic public IP
# Result: last-resort SSH via key auth even if all mesh VPN fails
```

---

## Step 6.4 — Phoenix Fallback Rate Alerting

Weekly cron on mushishi:
```bash
# Query Phoenix traces for last 7 days
# Calculate: (traces where provider != nemotron) / total_traces
# If > 10% → log alert, optionally send to Telegram/Discord webhook
# Script: /data/ai/01-workspace/scripts/check-fallback-rate.py
```

> Full script will be drafted when Phoenix is up and you have baseline trace data to query against.

---

---

# 📐 Working Methodology — Spec-Driven Development (SDD)

---

## SPEC.md Template

```markdown
# SPEC — [Task Name]
**Date:** YYYY-MM-DD | **Profile:** personal/uncensored | **Agent:** Hermes/DeerFlow/Claude

## Goal
One sentence: what must exist at the end that doesn't exist now.

## Inputs
- Data, files, APIs, or context the agent starts with

## Outputs
- File(s), endpoint(s), or state changes that must exist on completion
- Format and location

## Constraints
- Tech stack (e.g. Next.js 15, Tailwind, no external APIs)
- Style (e.g. Sanskrit typography, dark palette)
- What NOT to do

## Acceptance Criteria
- [ ] Criterion 1 (testable, binary yes/no)
- [ ] Criterion 2
- [ ] Criterion 3

## Out of Scope
- Related things explicitly excluded from this task

## Rollback Plan
- Files/dirs to snapshot: /data/ai/01-workspace, /data/ai/06-configs, ~/.hermes
- Services to restart post-restore: hermes-agent, vllm-nemotron
- Rollback command: auto-generated by sdd-snapshot.sh (see below)

---
Pre-task snapshot tag: (filled by sdd-snapshot.sh)
Rollback script: (auto-generated)
```

---

## SDD Scripts

### Initialize Spec Git Repo (once)

```bash
cd /data/ai/08-portfolio/specs
git init
git config user.name "Mushishi Stack"
git config user.email "stack@mushishi.local"
cat > .gitignore << 'EOF'
.rollback-*.sh
.snapshot-tracking
*.log
EOF
git add .gitignore
git commit -m "init: SDD spec repository"
```

### sdd-snapshot.sh (pre-task)

```bash
nano /data/ai/01-workspace/scripts/sdd-snapshot.sh
```

```bash
#!/bin/bash
# sdd-snapshot.sh — Pre-task Restic snapshot before any agent executes
# Usage: ./sdd-snapshot.sh --spec /data/ai/08-portfolio/specs/your-spec.md
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

BACKUP_REPO="/media/mushi/52B434D9B434C171/ai-backup-restic"
PASS_FILE="$HOME/.restic-password"
SPEC_PATH=""
while [[ $# -gt 0 ]]; do
  case $1 in --spec) SPEC_PATH="$2"; shift 2;; *) shift;; esac
done
[ -z "$SPEC_PATH" ] && echo "Usage: $0 --spec <path>" && exit 1
[ ! -f "$SPEC_PATH" ] && echo "SPEC not found: $SPEC_PATH" && exit 1

SPEC_NAME=$(basename "$SPEC_PATH" .md)
DATE_TAG=$(date '+%Y%m%d-%H%M%S')
FULL_TAG="pre-$SPEC_NAME-$DATE_TAG"

echo -e "${YELLOW}=== SDD Pre-Task Snapshot ===${NC}"
echo "Spec: $SPEC_NAME | Tag: $FULL_TAG"

restic -r "$BACKUP_REPO" --password-file "$PASS_FILE" backup \
  /data/ai/01-workspace \
  /data/ai/06-configs \
  "$HOME/.hermes" \
  "$SPEC_PATH" \
  --tag "$FULL_TAG" --tag "sdd-pre-task" --tag "$SPEC_NAME"

SNAP_ID=$(restic -r "$BACKUP_REPO" --password-file "$PASS_FILE" \
  snapshots --tag "$FULL_TAG" --latest 1 --json | \
  python3 -c "import sys,json; print(json.load(sys.stdin)[0]['id'])")

echo "" && echo -e "${GREEN}✅ Snapshot: $SNAP_ID${NC}"
echo "$DATE_TAG | $SPEC_NAME | $SNAP_ID | $FULL_TAG" >> /data/ai/08-portfolio/specs/.snapshot-tracking

# Generate rollback script
ROLLBACK="/data/ai/08-portfolio/specs/.rollback-$SPEC_NAME-$DATE_TAG.sh"
cat > "$ROLLBACK" << EOROLL
#!/bin/bash
echo "Rolling back to pre-task state for: $SPEC_NAME"
read -p "Type 'rollback' to confirm: " C
[ "\$C" != "rollback" ] && exit 1
sudo systemctl stop hermes-agent 2>/dev/null; docker stop vllm-nemotron 2>/dev/null || true
restic -r $BACKUP_REPO --password-file $PASS_FILE restore $SNAP_ID --target /
sudo systemctl start hermes-agent; forensic-mode.sh
echo "Rollback complete."
EOROLL
chmod +x "$ROLLBACK"
echo "Rollback script: $ROLLBACK"
echo ""
echo -e "${YELLOW}Rollback command:${NC}"
echo "restic -r $BACKUP_REPO --password-file $PASS_FILE restore $SNAP_ID --target /"
```

### sdd-verify.sh (post-task)

```bash
nano /data/ai/01-workspace/scripts/sdd-verify.sh
```

```bash
#!/bin/bash
# sdd-verify.sh — Post-task gate checks. Pass = commit snapshot. Fail = offer rollback.
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

BACKUP_REPO="/media/mushi/52B434D9B434C171/ai-backup-restic"
PASS_FILE="$HOME/.restic-password"
SPEC_PATH=""; ROLLBACK_ON_FAIL=false
while [[ $# -gt 0 ]]; do
  case $1 in --spec) SPEC_PATH="$2"; shift 2;; --rollback-on-fail) ROLLBACK_ON_FAIL=true; shift;; *) shift;; esac
done
SPEC_NAME=$(basename "$SPEC_PATH" .md)

echo -e "${GREEN}=== SDD Gate Verification: $SPEC_NAME ===${NC}"
ALL_PASS=true

check() {
  echo -n "  [$1] $2... "
  if eval "$3" > /dev/null 2>&1; then echo -e "${GREEN}PASS${NC}"
  else echo -e "${RED}FAIL${NC}"; ALL_PASS=false; fi
}

check "1"  "Hermes gateway health" "curl -sf http://localhost:8642/health"
check "1b" "Hermes dashboard"     "curl -sf -o /dev/null http://localhost:9119/"
check "1c" "Hermes dashboard remote-ready" "curl -sf -H \"X-Hermes-Session-Token: \$(grep '^HERMES_DASHBOARD_SESSION_TOKEN=' ~/.hermes/.env | cut -d= -f2-)\" http://\$(tailscale ip -4):9119/api/status"
check "2" "Nemotron GPU endpoint"  "curl -s http://localhost:8000/v1/models"
check "3" "Docker containers up"   "[ \$(docker ps --format '{{.Names}}' | wc -l) -gt 0 ]"
check "4" "Disk space /data < 90%" "[ \$(df /data/ai | tail -1 | awk '{print \$5}' | tr -d '%') -lt 90 ]"
check "5" "GPU accessible"         "nvidia-smi"

echo ""
if [ "$ALL_PASS" = true ]; then
  echo -e "${GREEN}=== ALL GATES PASSED ===${NC}"
  # Tag snapshot as verified
  SNAP=$(restic -r "$BACKUP_REPO" --password-file "$PASS_FILE" \
    snapshots --tag "sdd-pre-task" --tag "$SPEC_NAME" --latest 1 --json | \
    python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['id']) if d else print('')")
  [ -n "$SNAP" ] && restic -r "$BACKUP_REPO" --password-file "$PASS_FILE" tag "$SNAP" --add "verified-ok"
  restic -r "$BACKUP_REPO" --password-file "$PASS_FILE" forget --tag "sdd-pre-task" --tag "$SPEC_NAME" --keep-last 5 --prune
  echo "Snapshot committed and old pre-task snapshots pruned."
else
  echo -e "${RED}=== SOME GATES FAILED ===${NC}"
  ROLLBACK_SCRIPT=$(ls -t /data/ai/08-portfolio/specs/.rollback-$SPEC_NAME-*.sh 2>/dev/null | head -1)
  if [ "$ROLLBACK_ON_FAIL" = true ] && [ -n "$ROLLBACK_SCRIPT" ]; then
    echo "Auto-rolling back..."; bash "$ROLLBACK_SCRIPT"
  else
    echo "Manual rollback: $ROLLBACK_SCRIPT"
  fi
  exit 1
fi
```

```bash
chmod +x /data/ai/01-workspace/scripts/sdd-snapshot.sh
chmod +x /data/ai/01-workspace/scripts/sdd-verify.sh
```

### SDD Execution Flow (every coding task)

```bash
# 1. Write spec
nano /data/ai/08-portfolio/specs/2026-05-14-task-name.md

# 2. Pre-task snapshot (Mac alias: sdd-snap)
sdd-snapshot.sh --spec /data/ai/08-portfolio/specs/2026-05-14-task-name.md

# 3. Execute task (agent or manual)

# 4. Verify + commit (Mac alias: sdd-check)
sdd-verify.sh --spec /data/ai/08-portfolio/specs/2026-05-14-task-name.md
# Or with auto-rollback:
sdd-verify.sh --spec /data/ai/08-portfolio/specs/2026-05-14-task-name.md --rollback-on-fail

# 5. Commit spec to git
cd /data/ai/08-portfolio/specs && git add . && git commit -m "spec: task-name complete"
```

> **The rule:** No spec → no agent task. If writing the spec takes less than 5 minutes, write it anyway.

---

---

# 🤖 Dual Claude Code Workflow (v1.6.3 NEW)

The stack benefits from running Claude Code in two places simultaneously:

| Instance | Where | Sees | Best for |
|---|---|---|---|
| **Mushi-CC** | `mushishi` Linux box (via SSH or local terminal) | `journalctl`, `/proc`, systemd, all server config, root | Service config, log diagnosis, file ops, network state |
| **Mac-CC** | macOS terminal on the laptop | Browser DevTools, network requests, OS-level config, GUI apps | Client-side bugs, browser cookies/sessions, Mac app installs, the user-facing failure mode |

## When to use which

**Mushi-CC alone:** Pure Linux work — installing services, editing systemd units, debugging Hermes/vLLM logs, file system tasks on `/data/ai/`.

**Mac-CC alone:** Pure Mac work — installing PWAs, configuring browsers, setting up VS Code Remote-SSH, the Antigravity trial, Mac aliases in `~/.zshrc`.

**Both in parallel:** Client-server bugs. The Phase 2.5 `COOKIE_SECURE` bug is the canonical example — Mushi-CC saw the server returning 200 OK with a `Set-Cookie` header; Mac-CC saw the browser silently dropping that cookie because of `Secure` flag on HTTP. Neither side alone could have found it; together they nailed it in one round.

## Workflow pattern for client-server bugs

```
1. You describe the symptom to Claude (in the chat app)
2. Claude gives two prompts: one for Mushi-CC, one for Mac-CC
3. You paste each into the respective CC instance, in parallel
4. Each CC reports back its findings
5. Claude synthesizes the two reports into a diagnosis + fix
6. The CC instance closest to the fix applies it
7. The OTHER CC instance validates the fix from its end
```

The validation step is crucial — Mushi-CC saying "service is active" doesn't mean Mac-CC can actually use it. Always cross-validate.

## Example prompts (the Phase 2.5 final-gate pattern)

**Mushi-CC:** "The Hermes Workspace login is failing with 500 errors. Run `journalctl -u hermes-workspace -n 50`, identify the stack trace, and report which route handler is throwing. Also run `curl -X POST http://localhost:3001/api/auth -d '{\"password\":\"<from .env>\"}'` and report the response headers, especially Set-Cookie."

**Mac-CC (parallel):** "I'm trying to log into http://mushishi:3001 in Brave. Open Brave DevTools, attempt login, capture the POST /api/auth request and response. Pay close attention to Set-Cookie header attributes (Secure, HttpOnly, SameSite, Path). Report whether the cookie is actually accepted by the browser or rejected."

The combined output reveals: server sends cookie ✅, browser rejects because of `Secure` flag on `http://` ❌. Fix is `COOKIE_SECURE=0` in workspace `.env`.

## What NOT to do

- Don't expect Mushi-CC to debug browser behavior — it can't see what the browser does with responses
- Don't expect Mac-CC to read systemd journals — it has no access to the Linux box
- Don't paste credentials into either CC's chat history — both are still chat logs

## When this pattern was added

v1.6.3, after Phase 2.5 close-out. The COOKIE_SECURE bug consumed 8 chat-app exchanges before Mac-CC was deployed; once both CCs were running, the diagnosis took one round. That's a strong enough signal to formalize the workflow.

---

# 🛠️ gstack — Development Productivity Layer

> **Not part of the sovereign infrastructure.** gstack is a separate tool that sits on top of Claude Code (Claude API), not Hermes Agent. It's your development workflow accelerator for portfolio and SaaS work.

---

## What gstack Actually Is

gstack is a Claude Code skill pack — 20+ slash commands that give Claude Code specialized role personas: CEO, Engineering Manager, Designer, QA Lead, Security Officer, Release Engineer. Each slash command is a structured prompt that puts Claude Code in that specialist role for your project.

It's one of several popular Claude Code orchestration packs (Ruflo being the more maximalist alternative). The sprint flow is the value: `/office-hours` → `/plan-ceo-review` → `/plan-eng-review` → code → `/review` → `/qa` → `/ship`.

> **Before installing:** verify the GitHub repo URL, star count, and maintainer match your expectations. Skill packs in this space rebrand and fork frequently — pin the commit hash you install from in your portfolio specs git so you can reproduce later. Don't repeat attribution claims you haven't personally verified.

---

## Tier and Overlap

- **Tier:** T3 (cloud-explicit). gstack runs on Claude API, not local Nemotron.
- **Overlap with Ruflo:** Heavy. Both are Claude Code skill packs. Run one, not both — they will fight over slash command namespaces and CLAUDE.md sections.
- **Overlap with Hermes:** None — different tier, different purpose. Hermes is your sovereign agent. gstack is your cloud coding accelerator. They coexist cleanly because they don't compete.
- **Overlap with Paperclip:** None — Paperclip orchestrates, gstack executes. Paperclip can invoke Claude Code (with gstack skills) as one of its connected agents.

---

## The Hermes Integration (Optional)

gstack has an optional Hermes Agent integration:

```bash
cd ~/.claude/skills/gstack
./setup --host hermes
```

This installs gstack skills to `~/.hermes/skills/gstack-*/` — making gstack slash commands available as Hermes Agent skills.

> ⚠️ **Tier hygiene note:** Installing gstack skills into Hermes blurs the T2/T3 boundary. The skills are designed for Claude's reasoning — running them through local Nemotron will produce noticeably worse results. Only do this if you've tested the specific skills you care about against local Nemotron and confirmed they work. Otherwise, keep gstack on Claude Code only.

---

## Install (on Mac, after Claude Code is installed)

```bash
# Clone into Claude skills directory
git clone --single-branch --depth 1 <verified gstack repo URL> ~/.claude/skills/gstack

# Pin a commit hash for reproducibility (record in your specs repo)
cd ~/.claude/skills/gstack && git rev-parse HEAD
# Save this hash in /data/ai/08-portfolio/specs/dependencies.md

# Install (detects Claude Code, sets up slash commands)
./setup
```

The installer adds a gstack section to `CLAUDE.md` listing all available skills.

---

## Key Skills for Your Use Case

| Skill | Use it for |
|---|---|
| `/office-hours` | Start here — forces clarity on what you're actually building before code |
| `/autoplan` | CEO → Design → Eng review in one command |
| `/plan-eng-review` | Architecture, data flow, ASCII diagrams, edge cases |
| `/review` | Find bugs that pass CI but fail in production |
| `/qa` | Opens a real Chromium browser, clicks through your app, finds bugs |
| `/ship` | Sync, test, push, open PR |
| `/cso` | OWASP Top 10 + STRIDE security audit |
| `/design-shotgun` | Generate 4-6 design variants side-by-side in browser |

---

## GBrain — Persistent Memory Across Sessions

gstack includes GBrain, a persistent knowledge base that follows your agent across sessions. Run `/setup-gbrain` to initialize. Three storage options: PGLite (local, zero accounts), Supabase (cloud, syncs across machines), or existing Supabase URL.

For your stack, PGLite local is the sovereignty-first choice for development knowledge.

---

## Routine credential rotation (v1.6.3 — replaces v1.6.2 procedure)

Hermes API keys and workspace passwords rotate at least quarterly, or immediately after exposure (chat logs, screenshots, screen-share recordings).

### The three locations problem

The Hermes API key (`API_SERVER_KEY`) lives in **three places** and they must stay in sync:

```
~/.hermes/.env                                  ── main env (legacy, may have stale copy)
   ↓ overridden by ↓
~/.hermes/profiles/personal/.env                ── CANONICAL (gateway reads this)
   ↓ propagated to ↓
/data/ai/01-workspace/hermes-workspace/.env     ── workspace reads this (as HERMES_API_KEY / HERMES_API_TOKEN)
```

Any rotation must touch all three. v1.6.2's procedure missed the main `.env`, and the workspace `.env` propagation step was easy to skip.

### API key atomic rotation script

Save this as `/data/ai/00-bin/rotate-hermes-key.sh` and `chmod +x`:

```bash
#!/usr/bin/env bash
set -euo pipefail

NEW_KEY=$(openssl rand -hex 32)
echo "NEW KEY (save to Bitwarden NOW, do NOT echo or paste elsewhere):"
echo "$NEW_KEY"
echo ""
read -p "Saved? (y/N): " confirm
[ "$confirm" != "y" ] && { echo "Aborted, no changes made"; exit 1; }

# 1. Update profile (canonical)
sed -i.bak "s|^API_SERVER_KEY=.*|API_SERVER_KEY=$NEW_KEY|" ~/.hermes/profiles/personal/.env

# 2. Update main (clean up legacy reference if present)
if grep -q '^API_SERVER_KEY=' ~/.hermes/.env 2>/dev/null; then
  sed -i.bak "s|^API_SERVER_KEY=.*|API_SERVER_KEY=$NEW_KEY|" ~/.hermes/.env
fi

# 3. Update workspace (both KEY and TOKEN)
sed -i.bak \
  -e "s|^HERMES_API_KEY=.*|HERMES_API_KEY=$NEW_KEY|" \
  -e "s|^HERMES_API_TOKEN=.*|HERMES_API_TOKEN=$NEW_KEY|" \
  /data/ai/01-workspace/hermes-workspace/.env

# 4. Rebuild workspace (env vars are partly build-time-inlined)
cd /data/ai/01-workspace/hermes-workspace
pnpm build > /dev/null 2>&1

# 5. Restart all three services
sudo systemctl restart hermes-agent hermes-dashboard hermes-workspace
sleep 8

# 6. Validate — gateway accepts new key
echo ""
echo "=== Validation ==="
for svc in hermes-agent hermes-dashboard hermes-workspace; do
  printf "%-25s " "$svc:"
  systemctl is-active "$svc"
done

# 7. Validate — workspace can actually authenticate to gateway
GATEWAY_RESP=$(curl -sS -m 5 -w "\n%{http_code}" \
  http://localhost:8642/v1/models \
  -H "Authorization: Bearer $NEW_KEY")
HTTP_CODE=$(echo "$GATEWAY_RESP" | tail -1)
[ "$HTTP_CODE" = "200" ] && echo "Gateway auth: ✅ PASS" || echo "Gateway auth: ❌ FAIL (HTTP $HTTP_CODE)"

# 8. Remind operator to update Mac PWA
echo ""
echo "=== Next steps ==="
echo "1. Update Mac PWA: Settings → Gateway → API Key (paste new value)"
echo "2. Confirm chat works from PWA"
echo "3. Delete the .bak files once confirmed working:"
echo "   rm ~/.hermes/.env.bak ~/.hermes/profiles/personal/.env.bak \\"
echo "      /data/ai/01-workspace/hermes-workspace/.env.bak"

unset NEW_KEY
```

### Workspace password rotation

Similar pattern, but workspace `.env` only, and only the workspace needs to rebuild + restart:

```bash
#!/usr/bin/env bash
set -euo pipefail

NEW_PASS=$(openssl rand -hex 32)
echo "NEW PASSWORD (save to Bitwarden NOW):"
echo "$NEW_PASS"
read -p "Saved? (y/N): " confirm
[ "$confirm" != "y" ] && exit 1

sed -i.bak "s|^HERMES_PASSWORD=.*|HERMES_PASSWORD=$NEW_PASS|" \
  /data/ai/01-workspace/hermes-workspace/.env

# v1.7: hermes-workspace is retired — no rebuild or restart needed.
# The official Hermes Desktop app does not use HERMES_PASSWORD.
# Token-based auth is handled by HERMES_DASHBOARD_SESSION_TOKEN (see Step 2.5.2).
echo "v1.7: workspace PWA retired — password rotation step skipped."
echo "To update the dashboard session token, see the token rotation procedure in Step 2.5.2."

unset NEW_PASS
```

### When to do emergency rotation

- Credentials pasted into any LLM chat (Claude, ChatGPT, etc.) — chat history is a credential disclosure surface
- Visible in any screenshot or screen recording shared publicly
- Suspected unauthorized Tailscale device on the tailnet
- Personnel change on a multi-user variant of this stack

Routine quarterly rotation is good hygiene even without an incident.

---

# 🔧 Troubleshooting Reference

## Mac / OCLP (Sonoma)

| Symptom | Fix |
|---|---|
| UI sluggish / glitchy | OCLP Metal patch not applied — re-run Post-Install Volume Patch |
| `system_profiler` shows "Software Rendered" | Same as above |
| App crashes after Sonoma upgrade | Wrong build (ARM) — re-download x86_64 |
| RAM watcher not notifying | Check launchctl: `launchctl list | grep mushishi` — reload if absent |
| stats shows RAM > 14GB constantly | Close browser tabs first, then VS Code, then Aion UI |

## Firewall / Network

| Symptom | Fix |
|---|---|
| SSH blocked after firewall hardening | Tailscale down — `sudo tailscale up` on Linux first, then SSH |
| Service unreachable from Mac | Port not allowed on tailscale0 — `sudo ufw allow in on tailscale0 to any port XXXX` |
| Docker container reachable publicly | Docker bypasses UFW iptables — bind service to Tailscale IP specifically |

## Tailscale

| Symptom | Fix |
|---|---|
| `cannot resolve mushishi` | MagicDNS not enabled — admin.tailscale.com/dns |
| Connection drops on travel | DERP relay — normal. Phase 6 Headscale removes coordination dependency |
| `tailscale status` offline after reboot | `sudo tailscale up` — ensure `tailscaled` is enabled via systemctl |

## vLLM Nemotron (PRIMARY in v1.5)

| Symptom | Fix |
|---|---|
| Container exits during startup | `docker logs vllm-nemotron` — usually VRAM (drop `--max-model-len`) or `vllm[audio]` pip install timeout |
| `Quantization 'nvfp4' is not supported` | Container too old — confirm `vllm/vllm-openai:v0.20.0`, not earlier |
| `MoE backend flashinfer error` on consumer Blackwell | Already mitigated by `--moe-backend triton`. If still appears, flag isn't being parsed — check compose YAML formatting |
| OOM during weight load | Drop `--gpu-memory-utilization` to 0.88, or `--max-model-len` to 160000 |
| Multimodal request returns text-only response | Verify `--trust-remote-code` is set; image URL reachable from container; `--allowed-local-media-path` matches your `/mnt` mount |
| Pass 2 calls slow (no prefix-caching speedup) | Confirm `--enable-prefix-caching` in command. Caching only works if video URL is identical across calls. |
| Reasoning trace empty in response | Check `--reasoning-parser nemotron_v3` is set. Confirm request includes `extra_body.chat_template_kwargs.enable_thinking: true`. If still empty: `docker exec vllm-nemotron python3 -c "from openai import OpenAI; c=OpenAI(...); print(dir(c.chat.completions.create(...).choices[0].message))"` to find the actual attribute name in your vLLM build. |
| Audio inference fails (`librosa not found`) | Startup `pip install vllm[audio]` failed — check container logs, manually `docker exec -it vllm-nemotron pip install librosa soundfile` |

## Forensic Analyzer (NEW in v1.5)

| Symptom | Fix |
|---|---|
| `JSONDecodeError` on Pass 1 output | Model returned non-JSON wrapper — Pass 1 prompt expects strict JSON. Try lowering temperature in `make_reasoning_params` from 0.6 to 0.4 |
| Pass 2 parallel tasks crash with `Too many concurrent requests` | Drop `--max-num-seqs` in compose from 4 to 2; or rate-limit in script via `asyncio.Semaphore(2)` |
| Reasoning traces huge (10K+ tokens each) | Expected for hero elements. Stored separately on disk — doesn't impact context. Compress old jobs: `gzip /data/ai/08-portfolio/forensic/*/reasoning-traces/*.txt` |
| Bundle says "0 hero" for a video clearly containing people | Pass 1 didn't trigger — try the Pass 1 prompt at lower temperature, or check that the video URL is actually reachable from the container |

## Nemotron / NIM (DEPRECATED in v1.5 — kept for archive)

> Use the vLLM section above for current deployment. Below kept only as troubleshooting reference for the v1.3/v1.4 NIM path. See Decision Log §3-5 for why we moved away from it.

## Nemotron / NIM (GPU)

| Symptom | Fix |
|---|---|
| Container exits immediately | `docker logs nemotron-omni` — usually VRAM or bad NGC key |
| Endpoint times out | Still loading weights — wait 3 min, watch logs |
| NIM shows FP8 not NVFP4 in logs | GeForce safety fallback — try `NIM_MODEL_PRECISION=nvfp4` env var, or use vLLM + NVFP4 weights (Option C, Step 1.6) |
| VRAM usage ~30GB (expected ~15-18GB) | NIM defaulted to FP8 — see Step 1.6 precision verification |
| Prefix caching not confirmed in logs | This NIM build may not expose it in logs — do TTFT timing test to verify |
| VRAM not clearing | `fuser /dev/nvidia*` — find and kill holding process |
| `power.limit` shows 575W after reboot | systemd service failed — `sudo nvidia-smi -pl 450` manually |
| Concurrent agent throughput collapsed to 1-2 tok/s | KV cache thrash — too many concurrent sessions. Reduce concurrency or check Step 1.6 for NVFP4 vs FP8 |

## Nemotron CPU (llama.cpp)

| Symptom | Fix |
|---|---|
| Service fails to start | `journalctl -u nemotron-cpu -n 50` — usually OOM or GGUF path wrong |
| Response at < 5 tok/s | AVX-512 not enabled in build — rebuild with the CMake flags |
| OOMKiller kills the process | Reduce `MemoryMax` estimate was wrong — lower `-c 32768` context size |
| Model not found at path | Verify GGUF filename matches exactly in service ExecStart |

## Hermes Agent

| Symptom | Fix |
|---|---|
| Routes to cloud on uncensored | Check profile: `fallback: null` must be set (no nested fallback after CPU) |
| Groq fallback fails | `GROQ_API_KEY` in `~/.hermes/.env` — verify value, restart service |
| Skills not persisting | `~/.hermes/skills/` — never delete, check disk space |
| "queue/wait" behavior unclear | With `fallback: null`, Hermes returns error — not silent queue. Restart inference manually. |

## Hermes Agent + Workspace (v1.6 NEW)

### Critical: env var changes don't take effect without rebuild (v1.6.3)

The workspace is a Nuxt/SvelteKit-style app. Many config values get **inlined at build time** by `pnpm build`, not read at runtime. After ANY change to `/data/ai/01-workspace/hermes-workspace/.env`:

1. `cd /data/ai/01-workspace/hermes-workspace && pnpm build`
2. `sudo systemctl restart hermes-workspace`

Skipping step 1 produces the "I changed the value but nothing happened" failure mode. The credential rotation script in the Operations section handles this automatically; manual edits do not.

Variables observed to be **runtime-read** (no rebuild needed): `COOKIE_SECURE`, `TSS_PRERENDERING`, `TSS_SHELL`

When in doubt, rebuild. Cost: ~30 sec. Benefit: zero debugging time spent wondering if the change took effect.

| Symptom | Fix |
|---|---|
| `hermes dashboard: command not found` | `[web]` extras not installed — `pip install --break-system-packages 'hermes-agent[web]'` |
| `systemctl status hermes-agent` exits with status 2 right after restart | Unit still uses deprecated `hermes serve` — change ExecStart to `hermes gateway run`, `daemon-reload`, restart |
| `ss -tlnp \| grep 8642` shows `127.0.0.1` only | `API_SERVER_HOST=0.0.0.0` missing from `.env` — add it, restart `hermes-agent` |
| `ss -tlnp \| grep 8642` shows nothing | API server not enabled — `API_SERVER_ENABLED=true` missing from `.env` |
| `curl http://mushishi:8642/v1/models` returns `401` | This is correct — endpoint requires bearer auth. Use `-H "Authorization: Bearer $KEY"` |
| `curl http://mushishi:8642/health` from Mac → connection refused | UFW rule missing — `sudo ufw allow in on tailscale0 to any port 8642 proto tcp`, OR API server bound to loopback (see above) |
| `curl ...` from Mac → couldn't resolve `mushishi` | MagicDNS off — use raw Tailscale IP, or enable MagicDNS at admin.tailscale.com/dns |
| PWA loads, chat hangs, no response in `journalctl -u hermes-agent` | Hermes can't reach vLLM upstream — `docker ps \| grep vllm`, then check Phase 1 troubleshooting |
| PWA shows "API key invalid" | Mac PWA's saved key drifted from Mushishi's `.env`. Canonical value: `grep API_SERVER_KEY ~/.hermes/.env` — re-paste into PWA settings |
| CORS error in browser dev tools console | `API_SERVER_CORS_ORIGINS` doesn't include the URL your browser is using — add it to the comma-separated list, restart `hermes-agent` |
| `pnpm start` fails for hermes-workspace systemd unit | Script name varies by repo version — `cat package.json` in the workspace dir, substitute correct command (typically `pnpm preview` or a direct `node` invocation) |
| Workspace PWA disappears from Mac Dock after a few weeks | PWA is retired in v1.7 — use the official Hermes Desktop app instead (Step 2.5) |
| Official desktop app loses connection after mushishi reboot | Token not pinned — check `HERMES_DASHBOARD_SESSION_TOKEN` in `~/.hermes/.env` (Step 2.5.2) |
| "Test remote" fails in desktop app | Token mismatch or dashboard bound to 127.0.0.1 — verify `ss -tlnp \| grep 9119` shows tailscale IP, not loopback |
| `ExecStart= ...hermes... no such file or directory` in journal | Binary at `~/.local/bin/hermes`, not `/usr/local/bin/` | `which hermes`, update systemd unit ExecStart, `daemon-reload`, restart |
| `ModuleNotFoundError: No module named 'aiohttp'` on dashboard start | `[web]` extras didn't pull aiohttp despite needing it | `pip install --break-system-packages aiohttp`, restart `hermes-dashboard` |
| `Refusing to bind to non-loopback without --insecure` in dashboard logs | Hermes dashboard upstream safety gate | Add `--insecure` flag — see Step 2.4 for security rationale |
| `pnpm: command not found` or `node: command not found` in workspace journal | nvm binaries invisible to systemd | Install Node via NodeSource apt repo per Step 2.1.1; update unit ExecStart |
| Workspace service exits immediately with no clear error | `HERMES_PASSWORD` env var missing while `HOST=0.0.0.0` | Add `HERMES_PASSWORD=<openssl rand -hex 32>` to workspace `.env` |
| **PWA reports "API key invalid" despite key matching main .env** | **Profile-level `.env` is overriding with a different key** | **Pull canonical: `grep '^API_SERVER_KEY=' ~/.hermes/profiles/personal/.env`** |
| Stack appears healthy but uses unexpected CORS / URL values | Same precedence issue — profile `.env` overrides main `.env` | Always check both files; clean up duplicates per Step 2.3.1 |

## Paperclip (Phase 5.5)

| Symptom | Fix |
|---|---|
| Dashboard unreachable from Mac | Check `sudo ufw status` — port 3100 must be allowed on tailscale0 |
| Reachable from public internet | Wrong bind mode — re-run `npx paperclipai onboard --bind tailnet` |
| Agent shows "stuck" status | Heartbeat schedule too tight; agent runtime offline — check Hermes service |
| Budget exceeded warnings on local agent | Agent fell back to cloud (Kimi/Groq) — check Phoenix traces to confirm |
| Uncensored profile accidentally connected | Remove that adapter — T1 work never goes through orchestration |

## Backup / Restic

| Symptom | Fix |
|---|---|
| `unable to open config file` | External drive not mounted: `ls /media/mushi/` to check |
| Backup takes hours | Normal first run. Subsequent runs are incremental (minutes). |
| `restic check` reports errors | Run `restic repair snapshots` — check drive health with `smartctl -a /dev/sdX` |

## Observability

| Symptom | Fix |
|---|---|
| Netdata no GPU charts | Enable nvidia plugin in charts.d.conf, restart netdata |
| Phoenix no traces | Hermes tracing block missing from config.yaml — add + restart |
| Benchmark shows >15% degradation | Check thermal throttle (beast-status), background processes, recent updates |

---

# 📋 Quick Command Reference

## Daily Ops (from Mac)

```bash
beast                    # SSH into mushishi
beast-status             # GPU + thermal throttle + CPU Nemotron + Docker + RAM
beast-agent              # Start agent mode remotely
beast-creative           # Start creative mode remotely
beast-forensic           # v1.5 NEW: Start forensic mode (vLLM 180K config)
beast-client             # v1.5 NEW: Full client video pipeline (forensic-mode.sh)
beast-logs               # Follow Hermes Agent logs
beast-cpu-logs           # Follow CPU Nemotron logs
beast-backup             # Run backup script
beast-bench              # Run benchmark suite
netdata                  # Open Netdata in browser
phoenix                  # Open Arize Phoenix in browser
paperclip                # Open Paperclip dashboard (Phase 5.5)
nemotron-test            # Check GPU Nemotron from Mac
nemotron-cpu-test        # Check CPU Nemotron from Mac
sdd-snap                 # Pre-task SDD snapshot (add --spec arg on Linux)
sdd-check                # Post-task SDD gate verification
```

> **v1.5 alias additions to add to your `~/.zshrc`:**
> ```bash
> alias beast-forensic='ssh mushi@mushishi "/data/ai/01-workspace/scripts/forensic-mode.sh"'
> alias beast-client='ssh mushi@mushishi "/data/ai/01-workspace/scripts/client-job.sh"'
> ```

## On Linux (mushishi)

```bash
# Mode switching (v1.5)
forensic-mode.sh                   # Start vLLM Nemotron (180K, FP8 KV, EVS off)
agent-mode.sh                      # Lighter Nemotron config
creative-mode.sh 30                # T2+: full VRAM swap needed
creative-mode.sh 7                 # T1: exception check (7GB creative)
client-job.sh <video> <job_id>     # Full forensic pipeline for one client

# Services
sudo systemctl status hermes-agent
sudo systemctl status nemotron-cpu
sudo systemctl restart hermes-agent
docker ps

# GPU
nvidia-smi
nvidia-smi dmon -s u               # live VRAM
nvidia-smi --query-gpu=power.draw,temperature.gpu,clocks.throttle_reasons --format=csv,noheader

# Hermes
hermes profile list
hermes profile default uncensored
hermes profile default personal
hermes chat --profile personal "test"
hermes chat --profile uncensored "test"

# Backup
backup.sh
restic -r /media/mushi/52B434D9B434C171/ai-backup-restic snapshots --password-file ~/.restic-password

# SDD
sdd-snapshot.sh --spec /data/ai/08-portfolio/specs/specname.md
sdd-verify.sh --spec /data/ai/08-portfolio/specs/specname.md --rollback-on-fail
cd /data/ai/08-portfolio/specs && git log --oneline
```

---

# 📌 Key File Locations

| File | Purpose |
|---|---|
| `/data/ai/06-configs/vllm-nemotron/docker-compose.yml` | **v1.5 PRIMARY**: Nemotron deployment via vLLM 0.20.0 |
| `/data/ai/06-configs/nemotron/docker-compose.yml` | DEPRECATED v1.5: NIM container, kept for archive |
| `/data/ai/06-configs/trtllm/` | DEPRECATED v1.5: TRT-LLM attempt, kept for Decision Log reference |
| `/data/ai/06-configs/phoenix/docker-compose.yml` | Arize Phoenix |
| `/data/ai/06-configs/paperclip/` | Paperclip configs (Phase 5.5) |
| `/data/ai/06-configs/litellm/` | LiteLLM config (saved, not activated) |
| `/data/ai/01-workspace/paperclip/` | Paperclip install dir + embedded Postgres (Phase 5.5) |
| `/data/ai/01-workspace/nemotron-forensic/forensic_analyzer.py` | **v1.5 NEW**: 3-pass forensic orchestration |
| `/data/ai/01-workspace/nemotron-forensic/quick_describe.py` | **v1.5 NEW**: Single-pass describe (agent use) |
| `/data/ai/02-models/nemotron-nvfp4/` | **v1.5**: Nemotron NVFP4 weights (21GB) |
| `/data/ai/02-models/nemotron-nvfp4/modeling.py` | Patched with `**kwargs` (TRT-LLM journey artifact, harmless for vLLM) |
| `/etc/systemd/system/nemotron-cpu.service` | CPU Nemotron always-on service |
| `/etc/systemd/system/nvidia-power-limit.service` | GPU power limit persistence |
| `/data/ai/01-workspace/scripts/agent-mode.sh` | Switch to agent mode |
| `/data/ai/01-workspace/scripts/forensic-mode.sh` | **v1.5 NEW**: Start vLLM forensic config |
| `/data/ai/01-workspace/scripts/client-job.sh` | **v1.5 NEW**: Full forensic pipeline for one client |
| `/data/ai/01-workspace/scripts/creative-mode.sh` | Switch to creative mode (VRAM-aware) |
| `/data/ai/01-workspace/scripts/backup.sh` | Backup script |
| `/data/ai/01-workspace/scripts/benchmark.sh` | Performance regression detection |
| `/data/ai/01-workspace/scripts/harden-firewall.sh` | UFW hardening (run once) |
| `/data/ai/01-workspace/scripts/sdd-snapshot.sh` | Pre-task snapshot |
| `/data/ai/01-workspace/scripts/sdd-verify.sh` | Post-task gate verification |
| `/data/ai/01-workspace/unsloth/starter-finetune.py` | Unsloth QLoRA reference |
| `/data/ai/08-portfolio/specs/` | SDD specs (git repo) |
| `/data/ai/08-portfolio/specs/dependencies.md` | Pinned commit hashes for external tools (gstack, etc) |
| `/data/ai/08-portfolio/forensic/<job-id>/_final-bundle.json` | **v1.5 NEW**: ComfyUI conditioning input |
| `~/.hermes/config.yaml` | Hermes global config + tracing |
| `~/.hermes/.env` | API keys — Groq + OpenRouter (chmod 600) |
| `/data/ai/01-workspace/hermes-workspace/.env` | v1.6 NEW: Hermes Workspace env (API key, URLs — chmod 600) |
| `~/.hermes/profiles/personal.yaml` | Personal profile (T2 — nested fallback chain) |
| `~/.hermes/profiles/uncensored.yaml` | Uncensored profile (T1 — GPU→CPU→STOP) |
| `~/.hermes/profiles/client.yaml` | **v1.5 NEW**: Client profile (T1 — vLLM only, never falls back) |
| `~/.hermes/memory/` | Hermes persistent memory — NEVER DELETE |
| `~/.hermes/skills/` | Hermes learned skills — NEVER DELETE |
| `~/.restic-password` | Backup encryption key — KEEP SAFE (chmod 600) |
| `~/Library/LaunchAgents/com.mushishi.ram-watcher.plist` | Mac RAM watcher |
| `~/.zshrc` (Mac) | All Mac aliases (add `beast-forensic`, `beast-client` for v1.5) |
| `~/.ssh/config` (Mac) | SSH host config |

---

# 🔮 Future Additions

| Tool | Why deferred | When to add |
|---|---|---|
| **Headscale (Phase 6)** | VPS not ready yet | ~1 month — when VPS provisioned |
| **Remote Restic backup (Phase 6)** | VPS not ready yet | Same time as Headscale |
| **Phoenix fallback alerting** | Need baseline trace data first | After 2 weeks of Phoenix running |
| **LiteLLM (activated)** | Hermes routing covers current needs | When 5+ tools independently need configs |
| **Paperclip** | Single-agent workflows don't need an org chart | Phase 5.5 — when 3+ agents running with distinct workloads (Hermes + DeerFlow + Claude Code) |
| **Ruflo (formerly Claude Flow)** | T3 only (Claude API). Overlaps heavily with gstack — pick one. ~60-agent local swarms not realistic on RTX 5090 (see VRAM ceiling) | Only if dropping gstack AND have a heavy parallel coding workload that justifies Claude API spend |
| **gstack** | T3 Claude Code skill pack — see gstack section above | Install with Claude Code on Mac. If adopting Ruflo later, remove gstack |
| **DeerFlow queue integration** | Complex, low priority | Phase 5+ when creative work is daily |
| **Unsloth fine-tuning** | No specific fine-tuning goal yet | Phase 6+ with concrete goal |
| **Voice (Whisper + Piper)** | Nice to have, not core | After full stack is stable |
| **Prometheus + Grafana** | Netdata covers personal stack | Multi-node cluster only |
| **Docker rootless / userns-remap** | ComfyUI community doesn't support rootless well yet | When community support improves |
| **Kubernetes** | Docker Compose is sufficient | Multi-node cluster only |
| **Oh-My-Zsh on Mac** | Aesthetic overhead | Optional at any time |
| **OpenClaw** | Redundant with Hermes for now | If Hermes has channel gap you hit |
| **Forge / SwarmUI** | ComfyUI setup already mature | If ComfyUI management becomes friction |

---

## 🔄 Update Strategy

When updating any component (NIM image, Docker, NVIDIA drivers, Hermes Agent):

1. **Snapshot first:** `backup.sh` (or SDD snapshot for targeted changes)
2. **Update one component at a time** — never update multiple things simultaneously
3. **Run benchmark after GPU-affecting updates:** `benchmark.sh` — compare to previous CSV
4. **Verify all gates:** `beast-status`, `nemotron-test`, `hermes chat "test"`
5. **Wait 24h before next update** — let the system prove stability

---

## 🧭 Adoption Decision Loop

Whenever a new tool, framework, or "should I add X" question arises (from an LLM recommendation, a Hacker News post, a Twitter thread, anywhere), run it through the Tool Evaluation Checklist at the top of this document. Specifically:

1. Name its **tier** (T1/T2/T3/T4). Don't accept a tool's self-description; classify it by where its data and reasoning actually live.
2. Check for **overlap** with existing stack components. If two tools cover the same job, you pick one.
3. Sanity-check **hardware fit** against the VRAM concurrent ceiling (3-5 agents at NVFP4) or your cloud budget.
4. Name the **sovereignty trade-off** explicitly. Trading is fine; pretending you're not trading is not.
5. Plan the **reversibility** path before installing. Snapshot if the tool writes to skill/memory layers.

If a recommendation comes with breathless enthusiasm and no trade-offs, that's a signal — demand the trade-offs before acting.

---

---

# 📖 DECISION LOG — Why We Built It This Way

> This section documents the reasoning for every major architectural choice. It captures the multi-hour journey from v1.4 (NIM/TRT-LLM plan) to v1.5 (vLLM forensic pipeline), including the failures, dead ends, and pivots that shaped the final design.
>
> **Why this exists:** When you publish this stack on GitHub, the README explains *what* you built. This log explains *why*, and *what we tried that didn't work*. Future you (and anyone reading) benefits from the lessons more than the conclusion.

## §1 — Why Nemotron-3-Nano-Omni in the first place

The original v1.0 plan was built around general-purpose agentic AI. The model choice was driven by three factors that favored NVIDIA Nemotron-3-Nano-Omni-30B-A3B-Reasoning over open alternatives:

1. **Hybrid Mamba-Transformer MoE**: 30B total parameters, only 3B active per forward pass. This 10:1 sparsity ratio is the only way to get 30B-class accuracy on a single 32GB consumer GPU — most dense 30B models need 60+ GB. The Mamba layers handle long-context efficiency that pure-Transformer 30B models choke on.

2. **Native multimodal — not bolted-on**: NVFP4 weights bundle the C-RADIOv4-H vision encoder and Parakeet-TDT-0.6B-v2 audio encoder. Conv3D temporal compression in the architecture means video tokens come pre-compressed (every 2 frames → 1 token), which is the only way 256K context becomes practical for video.

3. **NVFP4 quantization for Blackwell**: NVIDIA designed this 4-bit block-scaled format for SM_120 hardware acceleration. The 21GB weight footprint (vs 33GB FP8, 62GB BF16) is the only quantization that gives both: weights fit on 32GB AND leaves room for context.

But the real driver — only fully understood during the v1.5 redesign — was the **commercial creative use case**. The collaborator on this project (managing the privacy-conscious clientele subscription tier) needs:
- **4K, 24-60fps output** for advertising and movie post-production
- **Local-only processing** of client video (privacy as a product feature)
- **Object/rain/vehicle removal** that doesn't hallucinate inconsistent shadows, reflections, or fabric textures

Current image/video AI tools fail at consistency because their conditioning prompts are too sparse. Nemotron solves this by being **a forensic-detail caption generator** — its descriptions become the constraints that bind FLUX/Wan/Hunyuan to consistent regeneration. The 4K output frame rate is the creative stack's job, not Nemotron's; Nemotron's job is "the cinematographer's notes."

## §2 — Why NIM was the original deployment target (v1.3/v1.4 plan)

NVIDIA NIM (NVIDIA Inference Microservice) was the v1.3/v1.4 plan because:
- NVIDIA published `nvcr.io/nim/nvidia/nemotron-3-nano-omni-30b-a3b-reasoning` as the "official" deployment container
- NIM is marketed as the production-grade path with TensorRT-LLM under the hood
- It promised auto-selection of NVFP4 on Blackwell hardware
- It abstracted the engine complexity behind a simple Docker run

The v1.4 doc was structured around this assumption: pull the NIM container, mount weights, run. Phase 1 was sized accordingly (~2.5 hours).

## §3 — TRT-LLM detour: 6+ hours of debugging that taught us why NIM was the wrong call

When Phase 1 actually started on May 14–15, the NIM/TRT-LLM path immediately revealed problems. Rather than abandoning, we systematically debugged each failure, accumulating real upstream knowledge. Here's the chronological log:

### §3.1 — First container attempt: schema errors
Used `nvcr.io/nvidia/tensorrt-llm/release:1.3.0rc13` (the cookbook-recommended container). The provided yaml config had fields that the actual Pydantic models in 1.3.0rc13 didn't accept. **Resolution**: introspected the Pydantic models in `/usr/local/lib/python3.12/dist-packages/tensorrt_llm/llmapi/llm_args.py` and rewrote the config to match the actual schema. The cookbook was out of date.

### §3.2 — Wrong subcommand
The cookbook says `trtllm-serve <model>` but 1.3.0rc13 requires `trtllm-serve serve <model>`. **Resolution**: added `serve` to the invocation.

### §3.3 — `mamba_ssm` and `causal_conv1d` missing
TRT-LLM 1.3.0rc13's container doesn't include the Mamba kernel dependencies that Nemotron's hybrid backbone needs. PyPI install fails because the prebuilt wheels target stable PyTorch, not NVIDIA's nightly (`torch 2.11.0a0+eb65b36914.nv26.02`). **Resolution**: compiled from source inside the container with:
- `MAMBA_FORCE_BUILD=TRUE` (skip GitHub prebuilt wheel lookup which fails DNS in container)
- `CAUSAL_CONV1D_FORCE_BUILD=TRUE`
- `TORCH_CUDA_ARCH_LIST=12.0` (build only for SM_120 — 7× faster than building for all archs)

Source build of mamba_ssm: ~5–15 min for CUDA kernel compilation. Persisted via Docker named volume.

### §3.4 — CUTLASS version conflict
`mamba_ssm`'s install upgrades `nvidia-cutlass-dsl` from 4.3.4 to 4.5.0. TRT-LLM 1.3.0rc13 is pinned to 4.3.4 and breaks at import time. **Resolution**: after installing mamba_ssm, downgrade with `pip install --no-deps "nvidia-cutlass-dsl==4.3.4"`. Mamba_ssm's compiled kernels don't need the matching CUTLASS at runtime — it bundles its own kernels via `tilelang`.

### §3.5 — `use_cache` kwarg error
Once TRT-LLM imports cleanly and starts loading the model, AutoDeploy calls `NemotronH_Nano_Omni_Reasoning_V3(config, use_cache=...)` but the model's custom `modeling.py` only accepts `config`. **Resolution**: patched `/data/ai/02-models/nemotron-nvfp4/modeling.py` line 76 to add `**kwargs`:
```python
def __init__(self, config: NemotronH_Nano_Omni_Reasoning_V3_Config, **kwargs):
```
Backup at `modeling.py.original`. This is a real upstream bug in the model's HuggingFace code — should be fixed by NVIDIA via PR.

### §3.6 — HF_HUB_OFFLINE blocking auxiliary downloads
The model's custom code reaches HuggingFace at runtime to fetch the C-RADIOv2-H vision encoder's auxiliary files (`feature_normalizer.py`, `adaptor_base.py`, etc.). Our `HF_HUB_OFFLINE=1` env var blocked these. **Resolution**: removed `HF_HUB_OFFLINE`, added a Docker volume so the downloads persist across restarts.

### §3.7 — Python deps for multimodal
The vision encoder needs `timm` and `open_clip_torch`. The audio encoder needs `librosa` and `soundfile`. Video needs `decord`. CLIP tokenizers need `ftfy` and `regex`. None of these are in the TRT-LLM container. **Resolution**: added `pip install --no-cache-dir timm open_clip_torch librosa soundfile decord ftfy regex` to the startup script.

### §3.8 — The terminal failure: `forward() missing pixel_values`
After all of the above, AutoDeploy reached the actual model construction and immediately died:
```
TypeError: NemotronH_Nano_Omni_Reasoning_V3.forward() missing 1 required positional argument: 'pixel_values'
```
This is the wall. AutoDeploy traces the model's `forward()` with text-only inputs during graph capture, but Nemotron's forward signature **requires** `pixel_values` (the model is multimodal-mandatory, not text-with-optional-image). AutoDeploy in TRT-LLM 1.3.0rc13 doesn't know how to construct dummy multimodal inputs for tracing.

**This isn't a one-line fix.** It's a fundamental "AutoDeploy doesn't support multimodal-mandatory models." We could try `--backend pytorch` instead of `--backend _autodeploy` to skip the tracing pass, but at this point we paused to research alternatives.

## §4 — Research: what NVIDIA actually uses for this model

Web search for the truth turned up four damning facts:

1. **NVIDIA's own Nemotron-3-Nano-Omni research paper** (April 2026) states: *"All measurements use a single NVIDIA B200 GPU and vLLM nightly as of 2026-04-19 with EVS 50%. Nemotron 3 Nano Omni is evaluated in NVFP4."* — NVIDIA benchmarks their own model on their own flagship hardware using vLLM, not TRT-LLM.

2. **HuggingFace model card for all three weight variants** (BF16, FP8, NVFP4) states explicitly: *"Required version: vLLM 0.20.0 is needed."*

3. **vLLM has an official dedicated blog post** announcing day-zero support including NVFP4 on Blackwell, 3D conv video kernels, EVS, and the `nemotron_v3` reasoning parser.

4. **NVIDIA's own model card admits**: *"TensorRT-LLM is not supported on Jetson. For Jetson deployments, vLLM, SGLang, Ollama, llama.cpp, and TensorRT Edge-LLM are supported."* (Implicitly: TRT-LLM Edge-LLM exists, the consumer-card TRT-LLM is a separate codebase with less coverage.)

The conclusion: **TRT-LLM 1.3.0rc13 is undertested for this specific model**. The cookbook's "happy path" works for text-only Nemotron-3 variants but the Omni multimodal variant exposes gaps in AutoDeploy. vLLM 0.20.0 is the production path NVIDIA themselves validate.

## §5 — Why the use case clarification changed the math entirely

A critical conversation mid-pivot: the user (in conversation with their commercial creative collaborator) clarified the real use case wasn't agent throughput — it was **commercial-grade creative work on pre-shot client video**. This reframed several decisions:

| Decision area | Before clarification | After clarification |
|---|---|---|
| Engine priority | Throughput (tok/s) | Multimodal completeness (video/audio/image) |
| Acceptable workflow | Concurrent (Nemotron + ComfyUI) | Sequential (Nemotron analyzes → flush → ComfyUI) |
| Frame sampling | 2 fps (agent-throughput default) | 8 fps (forensic detail default), per-request overridable |
| Context size | 65K (agent conversations) | 180K (forensic descriptions + reasoning + reference images) |
| Quality/speed tradeoff | Favor speed for agent responsiveness | Favor quality for client deliverables |
| EVS (Efficient Video Sampling) | Default 0.5 (drop 50% frames for throughput) | 0.0 (every frame analyzed — no missed details) |

This is when vLLM became not just the right *technical* call but the right *strategic* one. The 10-20% raw throughput edge TRT-LLM might have had over vLLM on Hopper/Blackwell text generation is irrelevant when the engine can't read video at all.

## §6 — Applying v1.4's Tool Evaluation Checklist in retrospect

The v1.4 doc has a five-question Tool Evaluation Checklist (Tier / Overlap / Hardware fit / Sovereignty trade-off / Reversibility). Applying it retroactively to the NIM/TRT-LLM choice:

1. **Tier:** NIM is T1 (local Docker container) — passes.
2. **Overlap:** No existing inference engine in the stack — passes.
3. **Hardware fit:** RTX 5090 SM_120 NVFP4 — *theoretically* fits, but TRT-LLM 1.3.0rc13 cookbook was tested on B200 (data center) not GeForce. **This is the question we should have asked harder.**
4. **Sovereignty trade-off:** Pure local, no trade-off needed.
5. **Reversibility:** Docker container, trivially removable. ✅

**Lesson:** The checklist passed on a surface read, but question 3 (hardware fit) needed a stronger sub-question: *has anyone actually validated this engine on consumer Blackwell with this specific model variant?* Going forward, hardware-fit means *empirically validated*, not *theoretically compatible*. We should have demanded an "NVIDIA actually benchmarked this combination publicly" sign-off before committing to NIM.

The vLLM choice passes the same checklist *with stronger evidence*: NVIDIA's own paper, the model card requirement statement, the dedicated vLLM blog post.

## §7 — Why 180K context (not 256K, not 200K)

The model's theoretical max is 256K. The user asked: why 180K and not 256K?

**Real math (post-iGPU switch):**
```
Total VRAM:                       32,100 MB
NVFP4 weights:                   -18,000 MB
Vision + audio encoders:         -1,800 MB
CUDA graphs + activations:       -2,000 MB
Multimodal buffers:              -1,500 MB
Safety margin:                   -1,500 MB
─────────────────────────────────────────────
Free for KV + per-sequence state: ~7,300 MB
```

So **~228K is the actual total-VRAM ceiling**, not 256K. The user correctly intuited that 256K was "too much" — 256K is `max_position_embeddings` (theoretical position cap), and physically the box runs out of *total* VRAM well before then.

> **Correction (2026-06-21) — this block originally read "FP8 KV cache, MoE 30B-A3B model: ~32 KB per token → ~228,000 tokens," implying ~228K was a *KV* ceiling. It is not.** The ~32 KB/token figure is a dense-transformer rate (all layers attend). Nemotron-3-Nano-Omni is a **NemotronH hybrid: only 6 of 52 layers attend**, so FP8 attention-KV is **~3,072 bytes/token** (= 2 × 6 × 2 × 128) — ~10× cheaper. At that rate the ~7.3GB free would hold ~2.5M tokens of attention-KV, which makes the point clear: **attention-KV is nowhere near the constraint.** The real ~228K ceiling is the *total*-VRAM ceiling (weights + graphs + multimodal buffers + per-sequence Mamba state + the small KV slice), not a KV-cache limit. 180K is chosen for total-allocation headroom under spiky multimodal loads, not because KV runs out. See theinvalid.me/blog/i-had-my-kv-cache-math-14x-wrong.

Options considered:
- 256K → **impossible** (math doesn't work)
- 220K → near-ceiling, real OOM risk under edge cases (heavy reasoning + reference images)
- 200K → comfortable, slight buffer
- 180K → very comfortable, ~25% headroom (user's choice — accepted)
- 131K → original v1.4 plan (too conservative given the forensic use case)

**User's reasoning (verbatim from conversation):** "I don't think we should push our limits for now till we actually see if we're hitting limits on 180. Then maybe we'll think about reaching 200. Let's keep it at a higher level and not overreach and make a crash."

This is the right call. The signal for "raise to 220K" is "we hit context-full errors in actual client work." Until then, 180K is excess capacity, not constraint.

## §8 — Why FP8 KV cache

FP8 KV cache halves the *attention*-KV memory per token. Effect:
- Quality impact for description tasks is **negligible** (FP8 KV is production-standard for description workloads in Anthropic and NVIDIA infra)
- The forensic use case is **description**, not generation chained against very-long-distance dependencies — the failure modes of FP8 KV (small accumulated errors over hundreds of dependent tokens) don't apply

> **Correction (2026-06-21):** the original line ("halves memory per token ~32KB → ~16KB," "Without FP8 KV we'd have been stuck at ~90K context") overstated KV's role on this model. Nemotron is a **NemotronH hybrid (6 of 52 layers attend)**, so attention-KV is already tiny — ~3 KB/token at FP8 (= 2 × 6 × 2 × 128), ~350K tokens/GiB. FP8 KV is kept for the small saving and the production-standard quality, but it is **not** what unlocks 180K context — total VRAM (weights + graphs + multimodal buffers + per-sequence Mamba state) is the real budget, and KV is a small slice of it. See theinvalid.me/blog/i-had-my-kv-cache-math-14x-wrong.

## §9 — Why EVS (video pruning) is disabled

vLLM's default `--video-pruning-rate 0.5` drops 50% of sampled video frames algorithmically. NVIDIA's own benchmark uses this for "9× throughput" headlines. But:

- EVS is designed for **agentic throughput** (real-time interactivity over many users)
- For **forensic description**, every frame we sample is a frame we want analyzed
- The "save 50% time" benefit is wrong trade for the "miss a detail" cost
- Especially for "remove this rain" workflows — rain droplet visibility *varies frame to frame*, and EVS might drop exactly the frames where the model would have caught the droplet pattern

Setting `--video-pruning-rate 0.0` costs ~30% throughput on video inference but guarantees no algorithmic frame dropping. For client work, this trade is obviously correct.

## §10 — Why the tiered triage (hero / secondary / category / atmospheric)

This came from a critical user insight mid-design: **"In a Mumbai street scene there are 200+ objects. You can't enumerate every rain droplet."**

The naive "describe everything in this video" prompt fails two ways:
1. Model hits context limits and triages randomly, producing inconsistent depth
2. For a 200-object scene, enumerating each is meaningless AND wrong (the model would hallucinate counts)

The triage solution:
- **Tier 1 (hero, max 5)**: Named subjects. Full forensic detail (3K-5K tokens each, 24K reasoning budget).
- **Tier 2 (secondary, max 15)**: Distinct but less prominent. Focused detail (~1K-2K tokens each, 12K reasoning).
- **Tier 3 (categorical density, max 10)**: Groups described statistically. "~12-15 motorbikes in middle-distance traffic, mostly black/red Honda Activas carrying 1-2 riders" — NOT 12 individual bike descriptions.
- **Tier 4 (atmospheric fields)**: Rain, smoke, lighting, dust. Described as **fields with characteristics**, not enumerated particles.

This handles both the Mumbai street case AND the simple commercial product shot case. Same script, different complexity. Hard caps (5 / 15 / 10) prevent runaway token consumption.

## §11 — Why we capture the reasoning trace

This came from a late-conversation user insight: "Why aren't we capturing what the model thinks?"

The model produces reasoning blocks (`<think>...</think>`) before its final structured output. By default these are discarded. But for client work, the reasoning is **provenance gold**:

- **Defensible work for clients**: If a client questions "how did you know the rain was at 45°?", we can show: "the model observed streak length-to-droplet-size ratio across frames N to N+30 and computed it."
- **Uncertainty signal**: When reasoning says "I'm not entirely sure if that's a sedan or hatchback, but the rear pillar angle suggests sedan" — that's a flag for human review.
- **Debugging bad outputs**: If a forensic description is wrong, the reasoning shows *where* the model went off course.
- **Quality stratification**: Hero subjects (Tier 1) keep their reasoning. Background categories (Tier 3) probably don't need it preserved — script can choose.

Implementation: capture `response.choices[0].message.reasoning_content` (separate from `.content`). vLLM with `--reasoning-parser nemotron_v3` exposes both. Store reasoning separately on disk (not fed back into subsequent prompts — it would blow context).

## §12 — Why the sequential workflow (not concurrent)

The user surfaced this and I should have raised it earlier: **the creative workflow is fundamentally sequential, not concurrent**.

```
Phase 1: Nemotron analysis  (Nemotron loaded, ~28-30 GB VRAM)
            ↓ JSON to disk
            ↓ VRAM flushed
Phase 2: Creative stack    (ComfyUI loaded, ~24-30 GB VRAM)
            ↓ Output generated
            ↓ VRAM flushed
Phase 3 (optional): Nemotron validation
```

This is **way better** than the earlier mental model of "Nemotron handles, ComfyUI immediately runs." Implications:

1. **More aggressive VRAM allocation for Nemotron**: Since ComfyUI isn't running concurrently, Nemotron can use up to 92% of VRAM (vs 80% I was originally planning for "concurrent ops"). This gives us the headroom for 180K context with FP8 KV cache.
2. **Mode-switch scripts mediate the transitions**: `forensic-mode.sh` (Nemotron up) → `client-job.sh` (analysis, JSON out) → manual flush → `creative-mode.sh` (ComfyUI up). The JSON sits on disk as the bridge between phases.
3. **No live VRAM contention**: Bigger context budget, faster inference, simpler ops.

## §13 — Why the iGPU switch matters (~1GB of total VRAM)

Before the switch, Xorg + gnome-shell were consuming ~1GB of VRAM on the RTX 5090. After plugging the monitor into the motherboard HDMI (driven by the Ryzen 9 9900X3D's integrated graphics), the 5090 has its full 32GB available.

This was a 10-minute downtime to do once and reap benefits for the life of the system.

> **Correction (2026-06-21) — this section used to claim "1GB = ~25,000 additional context tokens at FP8 KV cache." That math was wrong.** It costed KV as if Nemotron were a dense transformer (every layer attends). Nemotron-3-Nano-Omni is a **NemotronH Mamba-2 / Transformer-MoE hybrid: only 6 of its 52 layers do self-attention.** The Mamba-2 layers carry sequence state in a fixed-size recurrent state, not a growing KV-cache.
>
> Corrected attention-KV rate at FP8:
> ```
> bytes/token = 2 (K,V) × 6 (attention layers) × 2 × 128 (head dim) = 3,072 bytes/token (~3 KB/token)
> 1 GiB / 3,072 bytes ≈ ~350,000 tokens of attention-KV
> 500 MiB              ≈ ~170,000 tokens of attention-KV
> ```
> So freeing ~1GB is worth ~350K tokens of *attention-KV*, not ~25K — the original figure was ~14× too pessimistic because it multiplied by all 52 layers instead of the 6 that attend.
>
> **More importantly: attention-KV is NOT the binding constraint on this box.** Because it's so cheap on a hybrid, context is limited by *total* VRAM allocation — weights (~18GB NVFP4), CUDA graphs + activations, multimodal preprocessing buffers, and per-sequence Mamba state — not by KV. So the right reason to do the iGPU switch is "~1GB back in the total budget that's actually tight," not a KV-cache win. The ~228K context ceiling below is a total-VRAM ceiling, not a KV ceiling; 256K is `max_position_embeddings` (theoretical). Full write-up: theinvalid.me/blog/i-had-my-kv-cache-math-14x-wrong.

## §14 — Sovereignty tier integration with the v1.4 framework

The v1.4 doc introduced T1/T2/T3/T4 tiers. The v1.5 forensic pipeline slots in cleanly:

- **`client` Hermes profile** is **T1** (local, never falls back). This is stricter than the v1.4 `uncensored` profile (which falls back from GPU to CPU within local). The reason: forensic description that silently degrades to CPU GGUF would produce different-quality conditioning, breaking the consistency contract with the downstream creative stack.
- **Forensic-mode vLLM** is the **T1 inference path** — same engine, same port, same network rules — only the config differs from agent-mode.
- **The 3-5 concurrent agent ceiling from v1.4** still applies. Forensic mode uses `--max-num-seqs 4`, which intentionally aligns with the ceiling. Don't try to run multiple `forensic_analyzer.py` invocations in parallel against the same vLLM container — they'll thrash the KV cache.
- **Paperclip (Phase 5.5, T4)** must never invoke a `client`-profile Hermes adapter. Paperclip logs everything in audit trails; T1 client work belongs in direct script invocation (`client-job.sh`), not in an orchestrated workflow.

## §15 — Files preserved from the failed TRT-LLM attempt (intentionally)

The patches and configs from §3 are kept on disk even though we've moved to vLLM:

| File | Why kept |
|---|---|
| `/data/ai/02-models/nemotron-nvfp4/modeling.py` (patched with `**kwargs`) | Harmless for vLLM, makes file forward-compatible if NVIDIA later fixes via PR |
| `/data/ai/02-models/nemotron-nvfp4/modeling.py.original` | Backup so we can verify the patch was minimal |
| `/data/ai/06-configs/trtllm/` | Full compose + yaml — useful reference if TRT-LLM ever fixes the AutoDeploy multimodal gap |
| Docker volume `trtllm_trtllm-pip-cache` | Contains compiled mamba_ssm wheel — saves 15 min if we ever revisit TRT-LLM |
| Docker image `nvcr.io/nvidia/tensorrt-llm/release:1.3.0rc13` (62GB) | Optional removal — `docker rmi` to reclaim disk if storage pressure |

The "why we tried that" is more valuable than the "it didn't work" — these artifacts are an audit trail for anyone (including future you) wondering "did anyone try the obvious thing?"

---

## Glossary of v1.5 terms

- **NVFP4**: NVIDIA's 4-bit block-scaled floating-point quantization format, hardware-accelerated on Blackwell (SM_120). 4 bits per weight + small per-block scale factor. ~75% smaller than BF16 with negligible quality loss for inference.
- **MoE (Mixture of Experts)**: Architecture where the model has many "expert" sub-networks but only activates a few per forward pass. Nemotron-3-Nano-Omni: 30B total / 3B active per token.
- **NemotronH (Mamba-2 / Transformer-MoE hybrid)**: Nemotron-3-Nano-Omni is **not** a dense transformer. It interleaves Mamba-2 (state-space) layers, MoE feed-forward layers, and a *small* number of self-attention layers — **only 6 of its 52 layers do attention.** Consequence for VRAM: only those 6 layers contribute a growing KV-cache; Mamba-2 layers carry sequence info in a fixed-size recurrent per-sequence state (constant per token, not growing). So FP8 attention-KV is ~3 KB/token (= 2 × 6 × 2 × 128) ≈ ~350K tokens/GiB — far cheaper than the dense-transformer rate, and **not** the binding constraint on context. Cost KV against this architecture, not the transformer template. (See §7/§8/§13 corrections, 2026-06-21.)
- **A3B**: "Active 3 Billion" — refers to the 3B activated parameters per forward pass in this MoE.
- **C-RADIOv4-H**: NVIDIA's vision encoder used in Nemotron-Omni. Variable-resolution patch-based image processor producing 1024-13312 visual tokens depending on image complexity.
- **Parakeet-TDT-0.6B-v2**: NVIDIA's audio encoder. Resamples to 16kHz mono, produces log-mel spectrograms, applies 3 stride-2 conv subsampling layers.
- **Conv3D temporal compression**: Architecture feature that compresses every 2 video frames into 1 token representation. Captures motion before the LLM sees the sequence.
- **EVS (Efficient Video Sampling)**: vLLM feature that drops 50% of sampled video frames algorithmically for throughput. Useful for agent workloads, disabled for forensic work.
- **FP8 KV cache vs default**: The model's *weights* are NVFP4. The KV *cache* (per-request memory holding token representations) can be a different dtype. v1.5 uses FP8 KV cache because FP4 KV is not yet stable and FP8 is the production standard.
- **AutoDeploy**: TRT-LLM's automatic deployment backend that traces model `forward()` for optimization. Underbaked for multimodal-mandatory models in 1.3.0rc13.
- **Prefix caching**: vLLM feature that caches the KV representations of the prompt prefix across requests. For multi-pass against the same video, the video tokens are computed once and reused — 5-7× speedup on subsequent passes.
- **Reasoning budget**: For thinking-mode models, the maximum tokens allowed in the `<think>...</think>` reasoning trace before forcing the final answer. Larger budget = deeper reasoning = better quality on complex tasks, at cost of more inference time.
- **Grace period**: Tokens after the reasoning budget is exhausted where the model is allowed to "wrap up" its reasoning gracefully before being cut off.
- **Triton MoE backend**: vLLM's alternative MoE kernel implementation. Required on consumer Blackwell (RTX 5090/Pro 6000) due to a current FlashInfer MoE bug. Set via `--moe-backend triton`.
- **Forensic mode / Creative mode / Agent mode**: Three operational modes corresponding to three VRAM configurations of Nemotron + Creative stack. Sequential — never concurrent.

---

### §v1.6-1: Aion UI replaced with Hermes Workspace + Dashboard for Mac cockpit (May 2026)

**What changed:** Step 2.5 swapped from "Install Aion UI on Mac, point Custom provider at Mushishi" to "Install Hermes Workspace PWA on Mac, point at Hermes gateway on Mushishi over Tailscale."

**Why:**
1. **Aion UI is a multi-agent dispatcher, not a thin OpenAI client.** It requires both a provider (tokens) AND an agent CLI binary (loop driver) on the Mac. v1.5's Step 2.5 only configured the provider; the agent slot defaulted to Gemini CLI, which wasn't installed → `Agent 'Gemini CLI' CLI not found in PATH` on first message send.
2. **Installing Gemini CLI as the agent would violate Tier 1 sovereignty** by adding Google as a control-plane dependency (auth refresh, telemetry, potentially tool execution routing).
3. **Aion's Hermes Agent adapter exists** but is less battle-tested than its Gemini one, and bridging Aion's agent slot to Hermes' API server adds a second moving part with no upside over going direct.
4. **Hermes now ships first-party Mac tooling** — the Hermes Workspace browser app installs as a PWA on macOS, giving a native-feeling Dock app that speaks directly to the Hermes gateway with no intermediate CLI. This is the architecture v1.5 was reaching for; Hermes just got there first.

**Trade-offs accepted:**
- Lose Aion UI's file-tree browsing, 9-format file preview, and drag-drop upload features. Mitigation: Step 2.6 (deferred) reintroduces Aion as a secondary cockpit if/when these features are actually needed; for chat-and-agent work the workspace covers it.
- Add three systemd services to Mushishi (gateway, dashboard, workspace) instead of one. Mitigation: matches the docs' recommended posture, all three are first-party from Nous Research, and a single `journalctl -u hermes-*` filter covers all logs.

**Port corrections rolled in:**
- v1.5 referenced `7860` for Hermes (from an older Gradio-based build, predated current gateway).
- Actual gateway port is `8642`. Dashboard `9119`. Workspace `3000`.
- Patches 1, 8, 9 above propagate the correction through Phase 0 firewall, Phase 5.5.3 Paperclip adapter, and troubleshooting reference.

**Files touched by patch:**
- `harden-firewall.sh` (Phase 0)
- Step 2.1 (install command — added `[web]` extras)
- Step 2.3 (`.env` additions — API server enable + URLs)
- Step 2.4 (systemd unit fix + dashboard unit add)
- Step 2.5 (full rewrite)
- Step 5.5.3 (Paperclip adapter port)
- Troubleshooting Reference (new Hermes section)
- Backup-priority files list (added workspace .env)
- Decision Log (this entry)

---

### §v1.6.1-1: Port :3000 collision fix + stale 7860 cleanup (May 2026)

**What changed:**
1. Hermes Workspace PWA port moved from `:3000` → `:3001` to avoid assumed collision with DeerFlow. **v1.6.4 correction:** DeerFlow 2.0 actually uses :2026, not :3000 — the collision never existed. Workspace stays on :3001 (moving back isn't worth the churn). :3000 is now genuinely free. See §v1.6.4-5.
2. Three stale `:7860` references the v1.6 patch missed are now corrected: architecture ASCII diagram, firewall Tailscale-detected branch (this was a real bug — the wrong branch was patched), tcpdump verification comment.
3. `beast-status.sh` Hermes health check rewritten — previous version OR'd Hermes against Nemotron, which silently hid Hermes outages as long as vLLM was up. New version checks all three Hermes services (gateway, dashboard, workspace) independently with proper HTTP error detection (`curl -sf`).

**Why:** v1.6 patch had two real bugs (firewall branch, port collision) plus three cosmetic issues. The health-check bug is the kind of thing that would have wasted a Saturday afternoon — "everything looks green but nothing works" — so worth flagging in the Decision Log for posterity.

**Lesson for future patches:** When patching shell scripts with `if/else` branches, search for ALL instances of the changed value, not just the first hit. When introducing a new port reservation, search the whole document for that port first. When writing health checks, use `curl -sf`, not `curl -s` — silent success on 5xx is a worse failure mode than loud failure.

---

### §v1.6.2-1: Six execution discoveries from Phase 2.5 folded into spec (May 2026)

**What changed:** Phase 2.5 execution against the v1.6.1 spec surfaced six environmental footguns the spec didn't anticipate. All six are now captured in v1.6.2 so they don't recur on rebuild.

**The six:**
1. **`hermes` binary at `~/.local/bin/`, not `/usr/local/bin/`** — Ubuntu 24's PEP 668 managed-environment posture means `pip install --break-system-packages` lands in user-local bin by default. All systemd `ExecStart=` paths now parameterized via `which hermes` at install time. Patches A, B, C.
2. **`aiohttp` missing despite `[web]` extras** — Upstream Hermes packaging gap. Added explicit `pip install aiohttp`. Patch A.
3. **Dashboard refuses `0.0.0.0` without `--insecure`** — Upstream safety gate; our UFW + Tailscale posture satisfies the real concern. Flag added with security-rationale comment so it isn't stripped later. Patch C.
4. **nvm-managed Node invisible to systemd** — Switched to NodeSource apt-installed Node for system services; nvm remains fine for interactive dev. Cleanest separation between "system services" and "developer environment." Patches A, D, E, F.
5. **Workspace requires `HERMES_PASSWORD` when `HOST=0.0.0.0`** — Undocumented in workspace README; added to required `.env` block with strong default generation. Patch D.
6. **Profile-level `.env` overrides main `.env` with `override=True`** — The most important capture. Caused a strong randomly-generated `API_SERVER_KEY` to be silently replaced by a weak guessable value in profile-level `.env`. New Step 2.3.1 documents precedence model, designates canonical locations per variable, adds comment-block warnings to both `.env` templates. Patches G, H, I.

**Side effect — credential rotation procedure added:** During execution, both the API key and workspace password were pasted into an LLM chat session for handover. Both were promptly rotated to fresh `openssl rand -hex 32` values, and the experience surfaced the need for documented rotation procedure (Patch J). Counts as routine hygiene, not an incident, but the procedure now exists for the next time it's needed.

**Lessons for future patches:**
1. **Don't trust upstream extras-spec.** When a tool says `pip install foo[web]`, verify the actual imports work — packaging gaps in extras are common.
2. **Parameterize binary paths at install time.** Hardcoded `/usr/local/bin/` in systemd units is fragile across distros and install modes. `which X` at install time, substitute into the unit heredoc.
3. **Document config precedence aggressively.** The `.env` precedence problem (#6) is the kind of issue that makes operators distrust their tools. It costs hours to discover, minutes to document. Always pay the documentation cost up front.
4. **Capture execution discoveries fast.** Six gotchas in a single execution session is normal for any non-trivial install. Folding them back into the spec within a day, while context is fresh, prevents the "tribal knowledge" failure mode where the spec stays clean but the operator's head holds all the actual install knowledge.

---

### §v1.6.3-1: COOKIE_SECURE + Phase 2.5 close-out discoveries (May 21, 2026)

**What changed:** 11 items captured from execution between v1.6.2 publication and Phase 2.5 final gate close.

**The headline:** `COOKIE_SECURE=0` is mandatory in workspace `.env` for any HTTP-over-Tailscale deployment. Without it, login flow returns 200 + sets cookie + browser silently drops cookie (per RFC 6265 — Secure flag on http:// origin is invalid) + page reload fails with 500. Symptom looks like authentication failure but is actually session persistence failure. Found by Mac Claude Code via browser DevTools after 8 chat-app exchanges of failed server-side diagnosis from Mushishi.

**Why the diagnostic chain was so long:**
1. Recent credential rotation made stale-credential the obvious hypothesis (it wasn't)
2. Three locations of API key created plausible "config drift" stories (none were the bug)
3. The workspace's compiled bundle pattern (some env vars inlined, some runtime) created another plausible "stale build" story (also not the bug)
4. The actual bug required client-side (browser) observation, which only Mac Claude Code could provide

**Lesson:** For auth issues, the first diagnostic question should be "does the browser actually have a session cookie after login?" — not "is the credential correct?" The latter is too convergent on credentials when sessions are the more common failure mode.

**Other items folded in:**
- Phase Overview table refresh (Phases 1, 2 → ✅ COMPLETE)
- Node migration from nvm symlinks → NodeSource v22 LTS captured
- Workspace `ExecStart` line corrected to direct `node` invocation (v1.6.2 said `pnpm start`, actual was `node server-entry.js`)
- Real Gate 2.5 test added — service-level + functional + browser-level
- Browser compatibility note for Orion users (use Brave/Chrome for the workspace PWA specifically)
- Credential rotation procedure rewritten as atomic script with cross-location propagation and post-rotation validation
- Dual Claude Code workflow formalized as standard pattern for client-server debugging
- Phase 2.5 Lessons Learned section added (5h actual vs 55min spec'd, with time breakdown and process-improvement notes)

**Files touched by patch:**
- Phase Overview table (line ~401)
- Step 2.1.1 (Node version Node 20 → Node 22)
- Step 2.5.2 (workspace systemd unit ExecStart pattern)
- Step 2.5.2.c (workspace .env — added COOKIE_SECURE, HERMES_API_TOKEN, comments)
- Step 2.5 gate (full rewrite — functional test instead of service-level)
- Step 2.5.4 (Orion caveat)
- Routine credential rotation section (full rewrite)
- New section: Dual Claude Code Workflow
- New section: Phase 2.5 Lessons Learned
- Decision Log: this entry

**Lessons for future patches:**
1. When the symptom is auth-related, look at the FULL HTTP transaction (request + response + cookies + browser behavior), not just the credential.
2. Gates must test user-facing invariants, not just process liveness. `systemctl is-active` is necessary but not sufficient.
3. Spec-vs-reality drift accumulates fast during execution. Patches in flight (v1.6, v1.6.1, v1.6.2) require continuous re-syncing of "what's in the doc" against "what's on the machine" — discoveries made during patch application don't auto-fold back without a follow-up patch.
4. Client-server bugs require client-side observation. Server logs only show what the server did, not what the client experienced.

---

### §v1.6.4-1: CPU Nemotron → PRISM abliterated variant (May 22, 2026)

What changed: Phase 4.5 GGUF source changed from `bartowski/nvidia_Nemotron-Nano-30B-A3B-GGUF` (stock) to `Ex0bit/Elbaz-NVIDIA-Nemotron-3-Nano-30B-A3B-PRISM` (PRISM-abliterated), IQ4_XS quant (~19GB).

Why: CPU Nemotron is the always-on floor for personal (last resort) and uncensored (fallback floor). Stock Nemotron's trained refusals undermine the uncensored profile's purpose. PRISM is a higher-quality abliteration method (Projected Direction Isolation, SNR layer selection, dual-component modification, norm-preserving orthogonalization) with credible capability-preservation claims.

Architecture: Option A (single abliterated model for both profiles) chosen over B (two models) and C (single + per-profile prompts). Single-operator stack doesn't justify bifurcated models; matches tools-not-nannies thesis.

Trade-offs: personal gets abliterated behavior at CPU layer (mitigated by system-prompt guardrails). Client unaffected (never falls below GPU). Escape hatch: 10-min GGUF swap to revert.

**Execution discoveries (folded in from earlier §v1.6.4-1 draft):** bartowski GGUF repo 404 on HuggingFace; llama.cpp build 3571 doesn't support `nemotron_h_moe` architecture (fixed by pulling latest, build 9283); used `build-cpu/` dir to preserve CUDA build; dropped `MemoryMax=80G` (cgroup incompatibility with mlock), added `LimitMEMLOCK=infinity` instead; Hermes fallback format corrected to `fallback_providers:` top-level key.

### §v1.6.4-2: LiteLLM promoted to active cloud budget layer, Option B routing (May 22, 2026)

What changed: (1) personal fallback reordered GPU→CPU→cloud to **GPU→cloud→CPU** (CPU now last resort). (2) LiteLLM promoted from deferred Phase 5.1 config to active Phase 3 prerequisite, Docker service on :4000 + Postgres. (3) Cloud routing + free-tier budgets (Kimi→Groq→OpenRouter, per-provider caps) moved from Hermes YAML into LiteLLM. (4) Hermes retains sovereignty + local routing; uncensored/client never reference LiteLLM.

Why: Operator wanted free-tier token-limit tracking + hourly-reset awareness, native in LiteLLM (provider_budget_config + order + cooldown), not in Hermes' simple ordered fallback. Option B over A to keep sovereignty boundaries in Hermes — no config path for uncensored/client to reach cloud.

Trade-offs: +2 containers to maintain/back up. Cloud preferred over local CPU for personal (Tier-2 tradeoff accepted). LiteLLM cooldown is heuristic (3600s fixed), not derived from actual provider reset times.

Sovereignty verified: tcpdump during Gate 3.4 Tests 4 & 5 confirmed zero :443/:4000 traffic for uncensored/client at network level.

### §v1.6.4-3: LiteLLM Docker invocation requirements (May 22, 2026)

The `ghcr.io/berriai/litellm-database:main-latest` image requires `--config /app/config.yaml` passed explicitly as a container argument — it does not auto-discover the mounted config file. Also adopted `--env-file` for API keys (cleaner than multiple `-e` flags). Captured in `start-stack.sh`. Without the explicit `--config`, LiteLLM starts with an empty config and the cloud-fallback model group silently doesn't exist.

### §v1.6.4-4: Hermes profile schema + flag corrections (May 22, 2026)

Three small but blocking corrections found during execution:
1. Hermes profile provider type for OpenAI-compatible upstreams is `provider: custom`, NOT `provider: openai_compatible`.
2. `LITELLM_MASTER_KEY` belongs in `~/.hermes/profiles/personal/.env` (profile-scoped auth), not main `.env` — consistent with the Step 2.3.1 precedence model from v1.6.2.
3. llama.cpp server alias flag is `-a`, not `--alias`. Wrong flag causes the model to register under its filename, breaking the profile's priority-3 reference. Required re-running Phase 3 Test 3 after correction.

Lesson: flag syntax and schema field names can't be assumed from general knowledge — verify against the actual tool's `--help` or existing config files before writing systemd units or profile YAML.

### §v1.6.4-5: DeerFlow port correction — :2026, not :3000 (May 22, 2026)

DeerFlow 2.0 serves on :2026 (nginx frontend), not :3000 as v1.6.1 assumed. Consequence: the v1.6.1 decision to move Hermes Workspace from :3000 → :3001 solved a collision that never existed. Hermes Workspace stays on :3001 (moving back isn't worth the churn). :3000 is now genuinely free. Port-reservation map, firewall script, and aliases corrected to :2026.

Lesson: don't reserve ports based on assumed defaults. Check the actual service's bind port (`ss -tlnp` after first run) before reserving around it. The v1.6.1 churn was avoidable with one `ss` check.

### §v1.6.4-6: Operational findings — travel test + Antigravity (May 22, 2026)

Travel test (2013 MBP, Sonoma OCLP, mobile hotspot): Tailscale held a direct peer path through lid-close, no DERP fallback. Best-case travel posture confirmed for this hardware/network. Caveat: restrictive networks (CGNAT, corporate FW) may force DERP — re-test if encountered.

Antigravity: KEEP. 10-min trial under 14GB RAM, configured to Hermes :8642 personal profile. Complementary secondary cockpit alongside the Workspace PWA.

### §v1.7-1: Official Hermes Desktop replaces third-party PWA (Jun 4, 2026)

**Context:** At v1.6, the official desktop ran a full local agent — rejected for the Mac (violates "nothing runs independently on the Mac"). The `outsourc-e/hermes-workspace` PWA was used instead as a thin remote frontend.

**What changed:** Nous shipped a first-party Remote Gateway mode (Settings → Gateway → Remote gateway; env vars `HERMES_DESKTOP_REMOTE_URL` + token). The Mac app now connects to mushishi's dashboard over Tailscale and runs zero local inference — functionally what the PWA did, but first-party and Nous-maintained.

**Decision:** Adopt official desktop in Remote Gateway mode; retire the PWA and its service/clone/port.

**Two non-obvious requirements (cost real debugging time):**
1. The dashboard session token must be *pinned* via `HERMES_DASHBOARD_SESSION_TOKEN` env var in `~/.hermes/.env`. The dashboard otherwise mints a fresh random token on every start — not written to any log or config file, so uncopyable. In v0.14.0 this env var support doesn't exist upstream; a one-line patch to `web_server.py` adds it (`_SESSION_TOKEN = os.environ.get("HERMES_DASHBOARD_SESSION_TOKEN") or secrets.token_urlsafe(32)`). Must be re-applied after `hermes-agent` upgrades.
2. The dashboard must run with `--tui` or remote chat silently fails. `/api/status` passes and the app reports "Remote Hermes backend is ready" — but the chat WebSocket (`/api/ws` + `/api/pty`) is refused and chat does nothing. This is the #1 reported failure mode.

**Sovereignty:** unchanged. Mac holds only URL+token. All profiles, LiteLLM routing, memory, skills, sessions stay on mushishi. `uncensored` zero-egress preserved in Phoenix post-migration.

**v0.15.2 note:** The `pip install --upgrade hermes-agent` path was attempted during v1.7 migration but 0.15.2 has a packaging bug (missing `hermes_cli.dashboard_auth` subpackage — referenced in `web_server.py` line 4822 but absent from the wheel). Rolled back to 0.14.0 + local patch. Re-evaluate when 0.15.x is fixed upstream.

**Doc-staleness note during research:** a cached copy of the upstream Desktop page initially lacked the Remote Gateway section; the GitHub `main` source (`web-dashboard.md`) and freshly-indexed pages confirmed it. Treated GitHub `main` as authoritative.

---

*Document ends. Version 1.7 — June 4, 2026.*
*For any new Claude session: paste this document and say which Gate you last completed.*
*Reviewed and improved with: Claude (primary architect for v1.3 → v1.7), Gemini (initial v1.0 plan + comparative research), Kimi (v1.1 → v1.2 review). The v1.4 → v1.5 journey is documented in the Decision Log above; the v1.5 → v1.6 Aion → Hermes Workspace pivot is §v1.6-1; the v1.6 → v1.6.1 port fixes are §v1.6.1-1; the v1.6.1 → v1.6.2 execution discoveries are §v1.6.2-1; the v1.6.2 → v1.6.3 COOKIE_SECURE fix and Phase 2.5 close-out are §v1.6.3-1; the v1.6.3 → v1.6.4 PRISM decision, LiteLLM Option B, DeerFlow port correction, and schema fixes are §v1.6.4-1 through §v1.6.4-6; the v1.6.4 → v1.7 Hermes Desktop Remote Gateway migration is §v1.7-1.*
*v1.5 changes derived from six hours of TRT-LLM debugging on May 14–15, followed by a full architecture rethink informed by the commercial creative use case clarification. All reasoning preserved.*
