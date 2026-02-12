$ErrorActionPreference = "Stop"
$top = Import-Csv .\top_suspects.csv
$dir = ".\profiles"
if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

function Fetch-ProfileJson($name) {
  $headers = @{ "User-Agent"="Mozilla/5.0"; "Referer"="https://www.moltbook.com" }
  $urls = @(
    "https://www.moltbook.com/api/v1/agents/profile?name=$([uri]::EscapeDataString($name))",
    "https://www.moltbook.com/api/v1/agents/profile?handle=$([uri]::EscapeDataString($name))",
    "https://www.moltbook.com/api/v1/profile?name=$([uri]::EscapeDataString($name))",
    "https://www.moltbook.com/api/v1/users/profile?name=$([uri]::EscapeDataString($name))",
    "https://www.moltbook.com/api/v1/users/profile?handle=$([uri]::EscapeDataString($name))"
  )
  foreach ($u in $urls) {
    try {
      $r = Invoke-WebRequest -UseBasicParsing -Uri $u -Headers $headers -TimeoutSec 20
      if ($r.StatusCode -eq 200 -and $r.Content) { return $r.Content }
    } catch { }
  }
  return $null
}

foreach ($t in $top) {
  $name = $t.name
  $safe = ($name -replace '[^A-Za-z0-9_\-]','_')
  $out = Join-Path $dir ("profile_{0}.json" -f $safe)
  if (Test-Path $out) { continue }

  Write-Host "Fetching profile for $name"
  $json = Fetch-ProfileJson $name
  if ($json) { $json | Out-File $out -Encoding UTF8; Write-Host "Saved $out" }
  else { Write-Host "No profile found for $name" }
}
