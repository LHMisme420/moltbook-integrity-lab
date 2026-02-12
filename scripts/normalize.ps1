$ErrorActionPreference = "Stop"

$posts = @()
Get-ChildItem raw_*.json | Sort-Object Name | ForEach-Object {
  try {
    $j = Get-Content $_.FullName -Raw | ConvertFrom-Json

    if ($j.posts) {
      foreach ($p in $j.posts) {
        $posts += [pscustomobject]@{
          source_file = $_.Name
          id          = $p.id
          author      = $p.author
          created_at  = $p.created_at
          content     = $p.content
          url         = $p.url
        }
      }
    }

    foreach ($k in @("results","data","items")) {
      if ($j.$k) {
        foreach ($p in $j.$k) {
          if ($p.content -or $p.text) {
            $posts += [pscustomobject]@{
              source_file = $_.Name
              id          = $p.id
              author      = $p.author
              created_at  = $p.created_at
              content     = ($(if ($p.content) { $p.content } else { $p.text }))
              url         = $p.url
            }
          }
        }
      }
    }
  } catch {
    Write-Host "Parse failed:" $_.Name
  }
}

$posts | Where-Object { $_.author -or $_.content } |
  Export-Csv moltbook_posts.csv -NoTypeInformation -Encoding UTF8

Import-Csv moltbook_posts.csv |
  Group-Object author |
  Sort-Object Count -Descending |
  Select-Object @{n="author";e={$_.Name}}, @{n="posts";e={$_.Count}} |
  Export-Csv author_frequency.csv -NoTypeInformation -Encoding UTF8

"{0} posts written to moltbook_posts.csv" -f $posts.Count
"Saved author_frequency.csv"
