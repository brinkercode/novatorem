# This script is the same as what is included in SetUp.md, however with the added automation of creating the .env file docker is expecting.
# Script must be run in an elevated PowerShell session.
# Please run <-- Set-ExecutionPolicy RemoteSigned -Scope CurrentUser --> before running this script.

$ClientId = Read-Host "Client ID"
$ClientSecret = Read-Host "Client Secret"

Start-Process "https://accounts.spotify.com/authorize?client_id=$ClientId&response_type=code&scope=user-read-currently-playing,user-read-recently-played&redirect_uri=http://localhost/callback/"

$Code = Read-Host "Please insert everything after 'https://localhost/callback/?code='"

$ClientBytes = [System.Text.Encoding]::UTF8.GetBytes("${ClientId}:${ClientSecret}")
$EncodedClientInfo =[Convert]::ToBase64String($ClientBytes)

$Headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
    "Authorization" = "Basic $EncodedClientInfo"
}

$Body = @{
    grant_type = "authorization_code"
    redirect_uri = "http://localhost/callback/"
    code = $Code
}

$response = Invoke-RestMethod -Method Post -Uri "https://accounts.spotify.com/api/token" -Headers $Headers -Body $Body
$RefreshToken = $response.refresh_token

# Write environment variables to .env file
$envFilePath = ".env"
$envContent = @"
SPOTIFY_REFRESH_TOKEN=$RefreshToken
SPOTIFY_CLIENT_ID=$ClientId
SPOTIFY_SECRET_ID=$ClientSecret
"@
$envContent | Out-File -FilePath $envFilePath -Encoding utf8

Write-Host "Environment variables have been set."