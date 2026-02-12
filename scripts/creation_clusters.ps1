$ErrorActionPreference = "Stop"
$cre = Import-Csv .\account_creation.csv
$top = Import-Csv .\top_suspects.csv

$cre2 = $cre | Where-Object { $_.created_at -and $_.created_at -ne "" } | ForEach-Object {
  $_.created_at = [datetime]$_.created_at
  $_
}

# bucket by day
$buckets = $cre2 | Group-Object { $_.created_at.ToString("yyyy-MM-dd") } |
  Sort-Object Count -Descending |
  ForEach-Object {
    [pscustomobject]@{
      bucket_day = $_.Name
      accounts = $_.Count
      names = ($_.Group.name -join ";")
    }
  }

$buckets | Export-Csv .\creation_buckets_by_day.csv -NoTypeInformation

# map: name -> bucket size
$bucketMap = @{}
foreach ($b in ($cre2 | Group-Object { $_.created_at.ToString("yyyy-MM-dd") })) {
  foreach ($row in $b.Group) { $bucketMap[$row.name] = $b.Count }
}

$boosted = foreach ($t in $top) {
  $csz = 0
  if ($bucketMap.ContainsKey($t.name)) { $csz = [int]$bucketMap[$t.name] }

  $creation_boost =
    if ($csz -ge 7) { 30 }
    elseif ($csz -ge 4) { 15 }
    elseif ($csz -ge 2) { 5 }
    else { 0 }

  [pscustomobject]@{
    name = $t.name
    posts = [int]$t.posts
    agent_score = [double]$t.agent_score
    label = $t.label
    rank = [double]$t.rank
    creation_cluster_size = $csz
    creation_boost = $creation_boost
    rank_v2 = [math]::Round(([double]$t.rank + $creation_boost),2)
  }
}

$boosted | Sort-Object rank_v2 -Descending | Export-Csv .\top_suspects_rank_v2.csv -NoTypeInformation
"Saved creation_buckets_by_day.csv and top_suspects_rank_v2.csv"
