# Moltbook Integrity Lab — Proof Pack

## What this is
A reproducible pipeline that crawls public social APIs, normalizes posts, and produces ranked suspect lists with per-account evidence files.

## Key outputs
- top_suspects_rank_v3.csv (ranked)
- evidence_v3/ (sample posts + timestamps per suspect)
- receipts pack SHA256:
ACB081C07B5F35492A8F66CB545DAA55431F30D2AE5219DE7CE60E4BD1B33440

## Reproduce (PowerShell)
\\\powershell
git clone https://github.com/LHMisme420/moltbook-integrity-lab.git
cd moltbook-integrity-lab
.\scripts\collect.ps1
.\scripts\normalize.ps1
.\scripts\score.ps1
.\scripts\time_burst.ps1
# optional extras if present:
if (Test-Path .\scripts\fetch_profiles.ps1) { .\scripts\fetch_profiles.ps1 }
if (Test-Path .\scripts\extract_creation.ps1) { .\scripts\extract_creation.ps1 }
if (Test-Path .\scripts\network_edges.ps1) { .\scripts\network_edges.ps1 }
if (Test-Path .\scripts\rank_v3.ps1) { .\scripts\rank_v3.ps1 }
if (Test-Path .\scripts\evidence_report_v3.ps1) { .\scripts\evidence_report_v3.ps1 }
\\\

## What to review
Open:
- top_suspects_rank_v3.csv
- evidence_v3/evidence_*.txt
