# current path
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$PemPath = Join-Path $ScriptDir "CAEDGE_DEVELOPER.pem"

$EC2User = "ubuntu"
$EC2IP = "13.250.229.230"

if (-Not (Test-Path $PemPath)) {
    Write-Host "PEM does not exist: $PemPath" -ForegroundColor Red
    exit 1
}

Write-Host "Checking and starting docker services on EC2..." -ForegroundColor Yellow

$ScriptLines = @(
  'cd caedge.application.cloud.gateway || { echo "Directory not found"; exit 1; }',

  '# 第一次检查',
  'ALL_SERVICES=$(docker compose config --services | sort | paste -sd " " -)',
  'RUNNING_SERVICES=$(docker compose ps --services --filter status=running | sort | paste -sd " " -)',

  'if [ "$ALL_SERVICES" = "$RUNNING_SERVICES" ]; then',
  '  echo "All services are already running"',
  '  exit 0',
  'fi',

  '# 执行启动',
  'echo "Some services not running, starting..."',
  'docker compose up -d',

  '# 第二次检查',
  'sleep 5',  # 稍微等几秒，避免刚启动还没 ready
  'RUNNING_SERVICES=$(docker compose ps --services --filter status=running | sort | paste -sd " " -)',

  'if [ "$ALL_SERVICES" = "$RUNNING_SERVICES" ]; then',
  '  echo "All services started successfully"',
  'else',
  '  echo "Some services failed to start"',
  '  echo "Expected: $ALL_SERVICES"',
  '  echo "Running : $RUNNING_SERVICES"',
  'fi'
)

$BashScript = [string]::Join("`n", $ScriptLines)
$Base64Script = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($BashScript))
$RemoteCommand = "echo $Base64Script | base64 -d | bash"

try {
    ssh -i $PemPath "$EC2User@$EC2IP" "$RemoteCommand"
}
catch {
    Write-Host "fail to connect: $_" -ForegroundColor Red
}

Read-Host -Prompt "Done! Press any key to exit"
