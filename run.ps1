# Define the URL and paths
$repositoryUrl = "https://github.com/nickfour/temp-sc/archive/refs/heads/main.zip"
$tempDirectory = "$env:TEMP\temp-sc"
$zipFilePath = "$env:TEMP\temp-sc.zip"
$scriptPath = "$tempDirectory\temp-sc-main\sc.ps1"

# Create the temp directory if it doesn't exist
if (-Not (Test-Path $tempDirectory)) {
    New-Item -Path $tempDirectory -ItemType Directory | Out-Null
}

# Download the zip file
Invoke-WebRequest -Uri $repositoryUrl -OutFile $zipFilePath

# Extract the zip file
Expand-Archive -Path $zipFilePath -DestinationPath $tempDirectory -Force

# Temporarily change the execution policy to allow script execution
$originalPolicy = Get-ExecutionPolicy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Execute the PowerShell script
if (Test-Path $scriptPath) {
    . $scriptPath
} else {
    Write-Error "The script $scriptPath does not exist."
}

# Restore the original execution policy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy $originalPolicy -Force

# Clean up
Remove-Item -Path $zipFilePath -Force
