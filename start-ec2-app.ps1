# current path
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$PemPath = Join-Path $ScriptDir "CAEDGE_DEVELOPER.pem"

$EC2User = "ubuntu"
$EC2IP = "13.250.229.230"

if (-Not (Test-Path $PemPath)) {
    Write-Host "PEM does not exist: $PemPath" -ForegroundColor Red
    exit 1
}

Write-Host "Checking if all docker services are already running on EC2..." -ForegroundColor Yellow

# 使用单引号包裹 Bash 脚本内容，防止 PowerShell 执行任何 $ 或转义
$ScriptLines = @(
  'cd caedge.application.cloud.gateway || { echo "Directory not found"; exit 1; }',
  'ALL_SERVICES=$(docker compose config --services | sort | paste -sd " " -)',
  'RUNNING_SERVICES=$(docker compose ps --services --filter status=running | sort | paste -sd " " -)',
  'if [ "$ALL_SERVICES" = "$RUNNING_SERVICES" ]; then',
  '  echo "All services are running"',
  'else',
  '  echo "Some services not running, starting..."',
  '  docker compose up -d',
  '  echo "Docker started!"',
  'fi'
)

# 用 LF 拼接为单个脚本字符串
$BashScript = [string]::Join("`n", $ScriptLines)

# 编码为 base64
$Base64Script = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($BashScript))

# 构造远程解码 + 执行命令
$RemoteCommand = "echo $Base64Script | base64 -d | bash"

# 执行 SSH
try {
    ssh -i $PemPath "$EC2User@$EC2IP" "$RemoteCommand"
}
catch {
    Write-Host "fail to connect: $_" -ForegroundColor Red
}

Read-Host -Prompt "Done! Press any key to exit"
