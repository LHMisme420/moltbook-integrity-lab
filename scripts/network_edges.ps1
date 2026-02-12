$ErrorActionPreference = "Stop"
$posts = Import-Csv .\moltbook_posts.csv

function Extract-Name($author) {
  if ("$author" -match "name=([^}]+)") { return $Matches[1].Trim() }
  return "$author"
}

$norm = foreach ($p in $posts) {
  $name = Extract-Name $p.author
  $txt = "$($p.content)"

  $dom = $null
  if ($p.url) {
    try { $dom = ([uri]$p.url).Host.ToLower() } catch { }
  } elseif ($txt -match '(https?://\S+)') {
    try { $dom = ([uri]$Matches[1]).Host.ToLower() } catch { }
  }

  [pscustomobject]@{
    author = $name
    source_file = $p.source_file
    domain = $dom
  }
}

$edges = @()

# shared domains
$norm | Where-Object { $_.domain } | Group-Object domain | ForEach-Object {
  $authors = $_.Group.author | Sort-Object -Unique
  if ($authors.Count -ge 2) {
    for ($i=0; $i -lt $authors.Count; $i++) {
      for ($j=$i+1; $j -lt $authors.Count; $j++) {
        $edges += [pscustomobject]@{ a=$authors[$i]; b=$authors[$j]; type="shared_domain"; weight=1; key=$_.Name }
      }
    }
  }
}

# shared capture file (same endpoint dump)
$norm | Group-Object source_file | ForEach-Object {
  $authors = $_.Group.author | Sort-Object -Unique
  if ($authors.Count -ge 2) {
    for ($i=0; $i -lt $authors.Count; $i++) {
      for ($j=$i+1; $j -lt $authors.Count; $j++) {
        $edges += [pscustomobject]@{ a=$authors[$i]; b=$authors[$j]; type="shared_source"; weight=1; key=$_.Name }
      }
    }
  }
}

$collapsed = $edges |
  Group-Object a,b,type |
  ForEach-Object {
    $first = $_.Group | Select-Object -First 1
    [pscustomobject]@{ a=$first.a; b=$first.b; type=$first.type; weight=$_.Count }
  } |
  Sort-Object weight -Descending

$collapsed | Export-Csv .\network_edges.csv -NoTypeInformation
"Saved network_edges.csv"
