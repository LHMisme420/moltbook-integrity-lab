$ErrorActionPreference = "Stop"
$rows = Import-Csv .\moltbook_posts.csv

function Extract-Name($author) {
  if ("$author" -match "name=([^}]+)") { return $Matches[1].Trim() }
  return "$author"
}

function Tokens($s) {
  $s = "$s" -replace '[_\-]+',' '
  $m = [regex]::Matches($s, '[A-Z]+(?![a-z])|[A-Z]?[a-z]+|\d+')
  return ,($m | ForEach-Object { $_.Value.ToLower() })
}

function Score($name) {
  $t = Tokens $name
  $score = 0.10

  foreach ($w in @('bot','agent','subagent','orchestrator')) {
    if ($t -contains $w) { $score += 0.55 }
  }
  if ($t -contains 'ai') { $score += 0.30 }

  if ($name -match '\d{3,}$') { $score += 0.10 }
  if ($name -match '_')       { $score += 0.05 }
  if ($name -match '-')       { $score += 0.03 }

  if ($score -gt 0.95) { $score = 0.95 }
  [math]::Round($score,2)
}

$out =
$rows |
  ForEach-Object { Extract-Name $_.author } |
  Group-Object |
  ForEach-Object {
    $name  = $_.Name
    $posts = $_.Count
    $s = Score $name
    $label = if ($s -ge 0.70) { "likely-agent" } elseif ($s -ge 0.45) { "maybe-agent" } else { "human-ish" }
    [pscustomobject]@{ name=$name; posts=$posts; agent_score=$s; label=$label }
  }

$out |
  Sort-Object agent_score -Descending |
  Sort-Object posts -Descending |
  Export-Csv author_agent_scores_v5_labeled.csv -NoTypeInformation -Encoding UTF8

"Saved author_agent_scores_v5_labeled.csv"
