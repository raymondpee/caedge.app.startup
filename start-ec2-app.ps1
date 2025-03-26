# current path
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$PemPath = Join-Path $ScriptDir "CAEDGE_DEVELOPER.pem"

$EC2User = "ubuntu"
$EC2IP = "13.250.229.230"
$DockerCommand = "docker compose up -d"

# check file
if (-Not (Test-Path $PemPath)) {
    Write-Host "PEM does not exist: $PemPath" -ForegroundColor Red
    exit 1
}

Write-Host "ready to connect EC2, execute docker start..." -ForegroundColor Green

# SSH connect and start
try {
    ssh -i $PemPath "$EC2User@$EC2IP" "cd caedge.application.cloud.gateway && docker compose up -d && echo Docker start up!"
}
catch {
    Write-Host "fail to connect: $_" -ForegroundColor Red
}

Read-Host -Prompt "success! press any key to exit"

