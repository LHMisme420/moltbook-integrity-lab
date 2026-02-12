$ErrorActionPreference = "Stop"
$posts = Import-Csv .\moltbook_posts.csv
$top = Import-Csv .\top_suspects_rank_v3.csv | Select-Object -First 25

function Extract-Name($author) {
  if ("$author" -match "name=([^}]+)") { return $Matches[1].Trim() }
  return "$author"
}

$posts2 = foreach ($p in $posts) {
  $dt = $null
  try { $dt = [datetime]::Parse($p.created_at) } catch { }
  [pscustomobject]@{
    author_name = (Extract-Name $p.author)
    created_at  = $dt
    content     = $p.content
    source_file = $p.source_file
    id          = $p.id
    url         = $p.url
  }
}

$evDir = ".\evidence_v3"
if (Test-Path $evDir) { Remove-Item $evDir -Recurse -Force }
New-Item -ItemType Directory -Path $evDir | Out-Null

foreach ($t in $top) {
  $name = $t.name
  $safe = ($name -replace '[^A-Za-z0-9_\-]','_')
  $path = Join-Path $evDir ("evidence_{0}.txt" -f $safe)

  $lines = @()
  $lines += "NAME: $name"
  $lines += "RANK_V3: $($t.rank_v3)"
  $lines += "LABEL: $($t.label)"
  $lines += "AGENT_SCORE: $($t.agent_score)"
  $lines += "POSTS: $($t.posts)"
  $lines += "BURST_EVENTS: $($t.burst_events)"
  $lines += "CREATION_CLUSTER_SIZE: $($t.creation_cluster_size)"
  $lines += "NETWORK_DEGREE: $($t.network_degree)"
  $lines += ""
  $lines += "SAMPLE POSTS (up to 5):"
  $lines += "----------------------------------------"

  $samples = $posts2 |
    Where-Object { $_.author_name -eq $name } |
    Sort-Object created_at -Descending |
    Select-Object -First 5

  foreach ($p in $samples) {
    $lines += ""
    $lines += ("TIME: {0}" -f $(if ($p.created_at) { $p.created_at.ToString("s") } else { "N/A" }))
    $lines += ("SRC:  {0}" -f $p.source_file)
    if ($p.url) { $lines += ("URL:  {0}" -f $p.url) }
    $lines += ("ID:   {0}" -f $p.id)
    $lines += ("TEXT: {0}" -f ($p.content -replace "`r"," " -replace "`n"," "))
  }

  $lines | Out-File $path -Encoding UTF8
}

"Saved evidence_v3/"
