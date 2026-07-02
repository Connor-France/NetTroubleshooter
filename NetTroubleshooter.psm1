$PublicPath = Join-Path $PSScriptRoot 'Public'
$PrivatePath = Join-Path $PSScriptRoot 'Private'

Get-ChildItem -Path $PrivatePath -Filter '*.ps1' -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }

Get-ChildItem -Path $PublicPath -Filter '*.ps1' -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }
