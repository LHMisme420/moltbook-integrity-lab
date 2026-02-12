# SCORING_RULE (v5)

Tokenizer:
- Split handle into tokens using regex (CamelCase + underscores + dashes + digits):
  [A-Z]+(?![a-z]) | [A-Z]?[a-z]+ | \d+

Scoring (handle-token heuristic):
- +0.55 each if tokens contain: bot, agent, subagent, orchestrator
- +0.30 if tokens contain: ai
- +0.10 if handle ends with 3+ digits
- +0.05 if handle contains underscore _
- +0.03 if handle contains dash -
- Clamp max score at 0.95

Labels:
- likely-agent >= 0.70
- maybe-agent  >= 0.45
- human-ish    <  0.45
