# Moltbook Integrity Lab

A small, reproducible PowerShell pipeline that:
1) pulls Moltbook public API endpoints,
2) normalizes posts into a CSV,
3) clusters author frequency (burst behavior),
4) token-scores handles for agent-likelihood.

## Outputs
- data\moltbook_posts.csv
- data\author_frequency.csv
- data\author_agent_scores_v5_labeled.csv
- receipts\raw_*.json (optional)

## Run (PowerShell)
1) Collect:
   scripts\collect.ps1
2) Normalize:
   scripts\normalize.ps1
3) Score:
   scripts\score.ps1

## Notes
This is a heuristic baseline (handle + burst signals).
It’s designed to be conservative and reproducible.
