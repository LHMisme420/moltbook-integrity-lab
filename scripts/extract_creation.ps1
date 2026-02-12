$ErrorActionPreference = "Stop"
$dir = ".\profiles"
$files = Get-ChildItem $dir -Filter "profile_*.json" -File -ErrorAction Stop

$out = @()
$fields = @("created_at","createdAt","created","creation_time","createdOn","joined_at","joinDate","joinedAt")

foreach ($f in $files) {
  try {
    $j = Get-Content $f.FullName -Raw | ConvertFrom-Json

    $name = $null
    if ($j.name) { $name = $j.name }
    elseif ($j.handle) { $name = $j.handle }
    elseif ($j.user -and $j.user.name) { $name = $j.user.name }
    elseif ($j.user -and $j.user.handle) { $name = $j.user.handle }
    else { $name = ($f.BaseName -replace '^profile_','') }

    $raw = $null
    foreach ($k in $fields) {
      if ($j.PSObject.Properties.Name -contains $k) { $raw = $j.$k; break }
      if ($j.user -and ($j.user.PSObject.Properties.Name -contains $k)) { $raw = $j.user.$k; break }
    }

    $dt = $null
    if ($raw) { try { $dt = [datetime]::Parse("$raw") } catch { } }

    $out += [pscustomobject]@{
      name = $name
      created_raw = $raw
      created_at = $dt
      profile_file = $f.Name
    }
  } catch { }
}

$out | Export-Csv .\account_creation.csv -NoTypeInformation
"Saved account_creation.csv"
