# A basic smoke test script for nginx page 

param(
    [string]$BaseUrl = "http://localhost:8080"
)

$ErrorActionPreference = "Stop"

function Get-Page {
    param([string]$Url)

    try {
        return Invoke-WebRequest -Uri $Url -UseBasicParsing
    }
    catch {
        throw "Request failed for $Url. Start Nginx first and confirm it is listening on port 8080. $($_.Exception.Message)"
    }
}

$baseUrl = $BaseUrl.TrimEnd('/')

$health = Get-Page -Url "$baseUrl/health"
if ($health.StatusCode -ne 200) {
    throw "Health endpoint returned HTTP $($health.StatusCode), expected HTTP 200."
}

if ($health.Content.Trim() -ne "ok") {
    throw "Health endpoint returned '$($health.Content.Trim())', expected 'ok'."
}

$page = Get-Page -Url "$baseUrl/"
if ($page.StatusCode -ne 200) {
    throw "Release page returned HTTP $($page.StatusCode), expected HTTP 200."
}

$requiredLabels = @(
    "Release version",
    "Git commit SHA",
    "Image created at"
)

foreach ($label in $requiredLabels) {
    if ($page.Content -notmatch [regex]::Escape($label)) {
        throw "Release page does not contain the required metadata label: $label"
    }
}

Write-Host "Smoke test passed: $baseUrl returned the release page and a healthy response." -ForegroundColor Green
