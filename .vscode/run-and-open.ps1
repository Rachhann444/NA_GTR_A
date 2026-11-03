# Windows version of run-and-open.sh
# Runs docker compose, then opens the page of each service that was started.

$ErrorActionPreference = "Stop"

# Go to the project root (the folder above .vscode)
Set-Location (Join-Path $PSScriptRoot "..")

# Run docker compose with the same arguments VS Code passed in
docker compose @args
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Work out which services were requested (none given = all)
$services = @()
$skipNext = $false
foreach ($a in $args) {
    if ($skipNext) { $skipNext = $false; continue }
    switch -Regex ($a) {
        '^(-f|--file|-p|--project-name|--profile|--env-file)$' { $skipNext = $true; continue }
        '^-'  { continue }
        '^up$' { continue }
        default { $services += $a }
    }
}
if ($services.Count -eq 0) { $services = @("admin", "client") }

# Ports must match docker-compose.yaml
$urls = @{
    admin  = "http://localhost:8021"
    client = "http://localhost:8022"
}

foreach ($s in $services) {
    if ($urls.ContainsKey($s)) {
        Write-Host "Opening ${s}: $($urls[$s])"
        Start-Process $urls[$s]
    }
}
