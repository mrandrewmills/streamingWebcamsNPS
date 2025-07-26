<#
.SYNOPSIS
    Lists all streaming webcams from the NPS API.

.DESCRIPTION
    This script checks for an NPS API key, retrieves (or reuses) a cached copy of all webcams,
    and filters for webcams where `isStreaming` is true. It displays relevant info including
    title, URL, status, related parks, and tags.

.NOTES
    Requires an environment variable named `NPS_API_KEY`.
#>

# === CONFIGURATION ===
$apiKey = $env:NPS_API_KEY
$cacheFile = "webcams.json"
$today = (Get-Date).Date

# === STEP 1: Ensure API Key Exists ===
if (-not $apiKey) {
    Write-Error "Missing API key. Please set the NPS_API_KEY environment variable."
    exit 1
}

# === STEP 2: Load or Refresh Cache ===
$needRefresh = $true
if (Test-Path $cacheFile) {
    $lastModified = (Get-Item $cacheFile).LastWriteTime.Date
    if ($lastModified -eq $today) {
        $needRefresh = $false
    }
}

if ($needRefresh) {
    try {
        # First call: get total count
        $firstResp = Invoke-RestMethod -Uri "https://developer.nps.gov/api/v1/webcams?limit=1&api_key=$apiKey" -ErrorAction Stop
        $total = [int]$firstResp.total

        # Second call: get all webcam data
        $fullResp = Invoke-RestMethod -Uri "https://developer.nps.gov/api/v1/webcams?limit=$total&api_key=$apiKey" -ErrorAction Stop

        # Save response to file
        $fullResp | ConvertTo-Json -Depth 10 | Set-Content -Path $cacheFile -Encoding UTF8
        "Webcam data retrieved and cached in $cacheFile"
    }
    catch {
        Write-Error "Failed to retrieve webcam data from NPS API: $_"
        exit 1
    }
}

# === STEP 3: Load Cached Data ===
try {
    $webcamJson = Get-Content -Path $cacheFile -Raw | ConvertFrom-Json
    $webcams = $webcamJson.data
}
catch {
    Write-Error "Failed to parse cached webcam data: $_"
    exit 1
}

# === STEP 4: Filter for isStreaming ===
$streamingWebcams = $webcams | Where-Object { $_.isStreaming -eq $true }

if (-not $streamingWebcams) {
    "No streaming webcams found."
    exit 0
}

# === STEP 5: Display Results ===
foreach ($cam in $streamingWebcams) {
    "Title     : $($cam.title)"
    "URL       : $($cam.url)"
    "Status    : $($cam.status)"
    
    if ($cam.relatedParks) {
        $parks = ($cam.relatedParks | ForEach-Object { $_.fullName }) -join "; "
        "Parks     : $parks"
    }

    if ($cam.tags) {
        "Tags      : $($cam.tags)"
    }

    if ($cam.images -and $cam.images.Count -gt 0) {
        $img = $cam.images[0]
        "Image     : $($img.url)"
        if ($img.caption) {
            "Caption   : $($img.caption)"
        }
    }

    "-" * 60
}
