$ErrorActionPreference = "Stop"

# Inputs
$score = Import-Csv .\author_agent_scores_v5_labeled.csv
$posts = Import-Csv .\moltbook_posts.csv

# time bursts (optional)
$bursts = @()
if (Test-Path .\time_bursts.csv) { $bursts = Import-Csv .\time_bursts.csv }

# creation clusters (optional)
$cre = @()
if (Test-Path .\account_creation.csv) { $cre = Import-Csv .\account_creation.csv }

# network edges (optional)
$edges = @()
if (Test-Path .\network_edges.csv) { $edges = Import-Csv .\network_edges.csv }

function Extract-Name($author) {
  if ("$author" -match "name=([^}]+)") { return $Matches[1].Trim() }
  return "$author"
}

# posts by name (ground truth)
$postCounts = $posts | ForEach-Object { Extract-Name $_.author } |
  Group-Object | ForEach-Object { [pscustomobject]@{ name=$_.Name; posts=$_.Count } }

# burst events by name
$burstByName = @{}
if ($bursts.Count -gt 0) {
  $bursts | ForEach-Object { Extract-Name $_.author } |
    Group-Object | ForEach-Object { $burstByName[$_.Name] = $_.Count }
}

# creation bucket size by day
$creationBucket = @{}
if ($cre.Count -gt 0) {
  $cre2 = $cre | Where-Object { $_.created_at -and $_.created_at -ne "" } | ForEach-Object {
    $_.created_at = [datetime]$_.created_at
    $_
  }
  $byDay = $cre2 | Group-Object { $_.created_at.ToString("yyyy-MM-dd") }
  foreach ($g in $byDay) {
    foreach ($row in $g.Group) { $creationBucket[$row.name] = $g.Count }
  }
}

# network degree (how connected an author is by shared_domain/shared_source)
$degree = @{}
if ($edges.Count -gt 0) {
  foreach ($e in $edges) {
    $a = $e.a; $b = $e.b; $w = [int]$e.weight
    if (-not $degree.ContainsKey($a)) { $degree[$a] = 0 }
    if (-not $degree.ContainsKey($b)) { $degree[$b] = 0 }
    $degree[$a] += $w
    $degree[$b] += $w
  }
}

# Build rank v3
$final = foreach ($s in $score) {
  $name = $s.name

  $pc = ($postCounts | Where-Object { $_.name -eq $name } | Select-Object -First 1)
  $pcount = if ($pc) { [int]$pc.posts } else { [int]$s.posts }

  $bcount = if ($burstByName.ContainsKey($name)) { [int]$burstByName[$name] } else { 0 }
  $ccsz = if ($creationBucket.ContainsKey($name)) { [int]$creationBucket[$name] } else { 0 }
  $deg  = if ($degree.ContainsKey($name)) { [int]$degree[$name] } else { 0 }

  # weights (tunable, but sane defaults)
  $rank =
    ([double]$s.agent_score * 100) +      # handle signal dominates baseline
    ([math]::Min($pcount, 10) * 2) +      # activity
    ([math]::Min($bcount, 10) * 5) +      # burst signal
    ([math]::Min($ccsz, 10) * 3) +        # creation-date cluster
    ([math]::Min($deg, 20) * 1)           # network degree

  [pscustomobject]@{
    name = $name
    posts = $pcount
    agent_score = [double]$s.agent_score
    label = $s.label
    burst_events = $bcount
    creation_cluster_size = $ccsz
    network_degree = $deg
    rank_v3 = [math]::Round($rank,2)
  }
}

$final | Sort-Object rank_v3 -Descending | Export-Csv .\top_suspects_rank_v3.csv -NoTypeInformation
"Saved top_suspects_rank_v3.csv"
