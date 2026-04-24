# start_gaoqiang.ps1
# 快速启动 admin_api (Rails) 和 admin_web (Vite/Vue3) 两个开发服务
# Windows PowerShell 版本 - 动态检测启动状态

$PROJECT_ROOT = "D:\project\github\gaoqiang"
$API_DIR = Join-Path $PROJECT_ROOT "admin_api"
$WEB_DIR = Join-Path $PROJECT_ROOT "admin_web"
$API_PORT = 3000
$WEB_PORT = 5173
$API_LOG_FILE = [System.IO.Path]::GetTempPath() + "gaoqiang_api_$((Get-Process -Id $PID).Id).log"
$WEB_LOG_FILE = [System.IO.Path]::GetTempPath() + "gaoqiang_web_$((Get-Process -Id $PID).Id).log"

# 颜色输出
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }

# 清理端口占用
function Stop-PortProcess {
    param([int]$Port)
    $processId = (Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | Select-Object -First 1).OwningProcess
    if ($processId) {
        Write-Warning "  端口 $Port 被进程 $processId 占用，正在清理..."
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        return $true
    }
    return $false
}

# 等待服务启动 (动态轮询)
function Wait-ServiceReady {
    param(
        [string]$Name,
        [int]$Port,
        [string]$LogFile,
        [string[]]$SuccessPatterns,
        [int]$TimeoutSeconds,
        [int]$PollIntervalMs = 1000
    )

    $startTime = Get-Date
    $timeout = $startTime.AddSeconds($TimeoutSeconds)

    Write-Info "  检测 $Name 启动状态 (最多等待 ${TimeoutSeconds}秒)..."

    while ((Get-Date) -lt $timeout) {
        # 检查端口是否被监听
        $isListening = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
        if ($isListening) {
            # 额外检查日志中是否有成功启动的模式
            if (Test-Path $LogFile) {
                $logContent = Get-Content $LogFile -Tail 20 -ErrorAction SilentlyContinue
                foreach ($pattern in $SuccessPatterns) {
                    if ($logContent -match $pattern) {
                        $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)
                        Write-Success "  $Name 已就绪 (耗时：${elapsed}秒)"
                        return $true
                    }
                }
                # 端口已监听但没有匹配模式，也认为就绪
                $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)
                Write-Success "  $Name 已就绪 (耗时：${elapsed}秒)"
                return $true
            }
        }
        Start-Sleep -Milliseconds $PollIntervalMs
    }

    Write-Warning "  $Name 启动超时 (${TimeoutSeconds}秒)"
    return $false
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

# 步骤 2: 启动服务 (并行)
Write-Info "[2/4] 启动 admin_api (Rails)..."
Write-Info "[3/4] 启动 admin_web (Vite)..."

# 启动 Rails API
$apiStartInfo = New-Object System.Diagnostics.ProcessStartInfo
$apiStartInfo.FileName = "cmd.exe"
$apiStartInfo.Arguments = "/c cd /d `"$API_DIR`" && bin\rails server -p $API_PORT"
$apiStartInfo.RedirectStandardOutput = $true
$apiStartInfo.RedirectStandardError = $true
$apiStartInfo.UseShellExecute = $false
$apiStartInfo.CreateNoWindow = $true
$apiProcess = [System.Diagnostics.Process]::Start($apiStartInfo)
$apiProcess.OutputReader = [System.IO.StreamReader]::new($apiProcess.StandardOutput.BaseStream)
$apiProcess.ErrorReader = [System.IO.StreamReader]::new($apiProcess.StandardError.BaseStream)

# 异步读取日志
$apiLogTask = Task {
    while (-not $apiProcess.HasExited) {
        $line = $apiProcess.OutputReader.ReadLine()
        if ($line) { Add-Content -Path $API_LOG_FILE -Value $line }
        $errLine = $apiProcess.ErrorReader.ReadLine()
        if ($errLine) { Add-Content -Path $API_LOG_FILE -Value $errLine }
    }
}

# 启动 Vite 前端
$webStartInfo = New-Object System.Diagnostics.ProcessStartInfo
$webStartInfo.FileName = "cmd.exe"
$webStartInfo.Arguments = "/c cd /d `"$WEB_DIR`" && pnpm dev"
$webStartInfo.RedirectStandardOutput = $true
$webStartInfo.RedirectStandardError = $true
$webStartInfo.UseShellExecute = $false
$webStartInfo.CreateNoWindow = $true
$webProcess = [System.Diagnostics.Process]::Start($webStartInfo)
$webProcess.OutputReader = [System.IO.StreamReader]::new($webProcess.StandardOutput.BaseStream)
$webProcess.ErrorReader = [System.IO.StreamReader]::new($webProcess.StandardError.BaseStream)

# 异步读取日志
$webLogTask = Task {
    while (-not $webProcess.HasExited) {
        $line = $webProcess.OutputReader.ReadLine()
        if ($line) { Add-Content -Path $WEB_LOG_FILE -Value $line }
        $errLine = $webProcess.ErrorReader.ReadLine()
        if ($errLine) { Add-Content -Path $WEB_LOG_FILE -Value $errLine }
    }
}

Write-Host ""

# 步骤 3: 动态检测启动状态 (并行)
Write-Info "[4/4] 等待服务启动..."

# 并行等待两个服务
$apiWait = Wait-ServiceReady -Name "admin_api" -Port $API_PORT -LogFile $API_LOG_FILE -SuccessPatterns @("Listening on", "Puma starting") -TimeoutSeconds 30
$webWait = Wait-ServiceReady -Name "admin_web" -Port $WEB_PORT -LogFile $WEB_LOG_FILE -SuccessPatterns @("Local:", "ready in") -TimeoutSeconds 15

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  服务启动完成!" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

if ($apiWait) {
    Write-Success "  ✓ admin_api:  http://localhost:$API_PORT"
} else {
    Write-Warning "  ⚠ admin_api:  http://localhost:$API_PORT (可能未完全启动)"
}

if ($webWait) {
    Write-Success "  ✓ admin_web:  http://localhost:$WEB_PORT"
} else {
    Write-Warning "  ⚠ admin_web:  http://localhost:$WEB_PORT (可能未完全启动)"
}

Write-Host ""
Write-Host "提示：按 Ctrl+C 停止所有服务" -ForegroundColor Gray
Write-Host ""

# 等待进程结束
try {
    $null = [System.Console]::TreatControlCAsInput = $true
    while ($true) {
        if ([System.Console]::KeyAvailable) {
            $key = [System.Console]::ReadKey($true)
            if ($key.Key -eq 'C' -and $key.Modifiers -eq 'Control') {
                Write-Host "`n正在停止服务..." -ForegroundColor Yellow
                Stop-Process -Id $apiProcess.Id -Force -ErrorAction SilentlyContinue
                Stop-Process -Id $webProcess.Id -Force -ErrorAction SilentlyContinue
                Remove-Item $API_LOG_FILE -ErrorAction SilentlyContinue
                Remove-Item $WEB_LOG_FILE -ErrorAction SilentlyContinue
                break
            }
        }
        Start-Sleep -Milliseconds 500
    }
} catch {
    # Ctrl+C 被中断
    Stop-Process -Id $apiProcess.Id -Force -ErrorAction SilentlyContinue
    Stop-Process -Id $webProcess.Id -Force -ErrorAction SilentlyContinue
}
