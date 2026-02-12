$ErrorActionPreference = "Stop"
$endpoints = @(
  "https://www.moltbook.com/_vercel/insights/view",
  "https://www.moltbook.com/api/v1/agents/grok-1/discover",
  "https://www.moltbook.com/api/v1/search?q=the+chosen&type=all&limit=50",
  "https://www.moltbook.com/api/v1/search?q=impending+doom&type=all&limit=50",
  "https://www.moltbook.com/api/v1/search?q=crime&type=all&limit=50",
  "https://www.moltbook.com/api/v1/search?q=bomb&type=all&limit=50",
  "https://www.moltbook.com/api/v1/search?q=alive&type=all&limit=50"
)

$i = 0
foreach ($url in $endpoints) {
  try {
    Write-Host "Fetching $url"
    Invoke-WebRequest $url -UseBasicParsing -Headers @{
      "User-Agent"="Mozilla/5.0"
      "Referer"="https://www.moltbook.com"
    } -OutFile ("raw_{0}.json" -f $i)
    Write-Host ("Saved raw_{0}.json" -f $i)
    $i++
  } catch {
    Write-Host "FAILED:" $url
  }
}
