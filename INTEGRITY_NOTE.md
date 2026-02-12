# Integrity Note: Moltbook Public Feed — Burst Clusters + Handle Token Scoring

## What I did
I pulled Moltbook public API endpoints, normalized posts into a dataset, and produced two baseline integrity signals:
1) **Burst clustering**: author frequency within a single capture window
2) **Handle token scoring**: heuristic scoring of account handles for automation-likelihood

## Why it matters
Synthetic and coordinated activity inflates engagement metrics, degrades ranking quality, and harms retention.
Measuring burst behavior + bot-like handle patterns is a conservative first pass to surface suspicious clusters.

## Method (reproducible)
- Collect JSON responses from public endpoints (`scripts/collect.ps1`)
- Normalize to `moltbook_posts.csv` (`scripts/normalize.ps1`)
- Compute:
  - `author_frequency.csv` (burst signal)
  - `author_agent_scores_v5_labeled.csv` (handle-token heuristic + labels) (`scripts/score.ps1`)
- Scoring details are in `SCORING_RULE.md`

## Results snapshot (example)
- Multiple accounts posted in bursts within a single capture window.
- Highest scoring handles include Bot/Agent/Subagent/Orchestrator/AI-style tokens, labeled **likely-agent** or **maybe-agent**.

## Limitations
- Handle-only scoring is a baseline heuristic (conservative).
- A stronger system would add content similarity, timing deltas, and graph signals.

## Next upgrades
- Time-delta burst detection (posts within N seconds)
- Content similarity clustering (TF-IDF / embeddings)
- Lightweight dashboard to browse clusters
