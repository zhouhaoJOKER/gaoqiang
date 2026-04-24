# start_gaoqiang.ps1
# 快速启动 admin_api (Rails) 和 admin_web (Vite/Vue3) 两个开发服务
# Windows PowerShell 版本 - 动态检测启动状态

$PROJECT_ROOT = "D:\project\github\gaoqiang"
$API_DIR = Join-Path $PROJECT_ROOT "admin_api"
$WEB_DIR = Join-Path $PROJECT_ROOT "admin_web"
$API_PORT = 3000
$WEB_PORT = 5173

# 颜色输出
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }

# 检查并清理端口占用
function Stop-PortProcess {
    param([int]$Port)
    $conn = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($conn) {
        Write-Warning "  端口 $Port 被占用，正在清理进程 $($conn.OwningProcess)..."
        Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        return $true
    }
    return $false
}

# 检查端口是否被监听
function Test-PortListening {
    param([int]$Port)
    $conn = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
    return $null -ne $conn
}

# 主流程
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  启动 gaoqiang 项目开发环境" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 步骤 1: 检查并清理端口
Write-Info "[1/4] 检查端口占用情况..."
$apiPortCleaned = Stop-PortProcess -Port $API_PORT
$webPortCleaned = Stop-PortProcess -Port $WEB_PORT

if (-not $apiPortCleaned) { Write-Info "  端口 $API_PORT 可用" }
if (-not $webPortCleaned) { Write-Info "  端口 $WEB_PORT 可用" }

Write-Host ""

# 步骤 2 & 3: 并行启动两个服务
Write-Info "[2/4] 启动 admin_api (Rails)..."
Write-Info "[3/4] 启动 admin_web (Vite)..."

# 启动 Rails API
Start-Process powershell.exe -ArgumentList "-NoExit", "-Command", "cd '$API_DIR'; bin/rails server -p $API_PORT" -WindowStyle Normal
$apiStartTime = Get-Date

# 启动 Vite 前端
Start-Process powershell.exe -ArgumentList "-NoExit", "-Command", "cd '$WEB_DIR'; pnpm dev" -WindowStyle Normal
$webStartTime = Get-Date

Write-Host ""

# 步骤 4: 动态检测启动状态
Write-Info "[4/4] 等待服务启动..."

$apiReady = $false
$webReady = $false
$maxWait = 30
$pollInterval = 1

for ($i = 1; $i -le $maxWait; $i++) {
    Start-Sleep -Seconds $pollInterval

    # 检测 Rails API
    if (-not $apiReady -and (Test-PortListening -Port $API_PORT)) {
        $apiElapsed = [math]::Round(((Get-Date) - $apiStartTime).TotalSeconds, 1)
        Write-Success "  ✓ admin_api 已就绪 (耗时：${apiElapsed}秒)"
        $apiReady = $true
    }

    # 检测 Vite 前端
    if (-not $webReady -and (Test-PortListening -Port $WEB_PORT)) {
        $webElapsed = [math]::Round(((Get-Date) - $webStartTime).TotalSeconds, 1)
        Write-Success "  ✓ admin_web 已就绪 (耗时：${webElapsed}秒)"
        $webReady = $true
    }

    # 两个都就绪就退出
    if ($apiReady -and $webReady) { break }
}

# 超时警告
if (-not $apiReady) { Write-Warning "  ⚠ admin_api 启动超时" }
if (-not $webReady) { Write-Warning "  ⚠ admin_web 启动超时" }

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  服务启动完成!" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Success "  ✓ admin_api:  http://localhost:$API_PORT"
Write-Success "  ✓ admin_web:  http://localhost:$WEB_PORT"
Write-Host ""
Write-Host "提示：关闭 PowerShell 窗口可停止服务" -ForegroundColor Gray
Write-Host ""
