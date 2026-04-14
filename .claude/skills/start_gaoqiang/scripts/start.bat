@echo off
REM start_gaoqiang.bat
REM 启动 admin_api 和 admin_web 两个项目的开发服务

setlocal enabledelayedexpansion

set PROJECT_ROOT=D:\project\github\gaoqiang
set API_DIR=%PROJECT_ROOT%\admin_api
set WEB_DIR=%PROJECT_ROOT%\admin_web
set API_PORT=3000
set WEB_PORT=5173

echo ======================================
echo   启动 gaoqiang 项目开发环境
echo ======================================

REM 检查并清理端口
echo.
echo [1/4] 检查端口占用情况...

for %%P in (%API_PORT% %WEB_PORT%) do (
    netstat -ano ^| findstr ":%%P " >nul
    if !errorlevel! equ 0 (
        echo   端口 %%P 已被占用，尝试清理...
        for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%%P " ^| findstr LISTENING') do (
            echo   终止进程 %%a ...
            taskkill /F /PID %%a 2>nul
        )
        timeout /t 2 >nul
    ) else (
        echo   端口 %%P 可用
    )
)

REM 启动服务
echo.
echo [2/4] 启动 admin_api (Rails)...
cd /d "%API_DIR%"
start "admin_api" /B bin\rails server -p %API_PORT%
echo   admin_api 启动中...

echo.
echo [3/4] 启动 admin_web (Vite)...
cd /d "%WEB_DIR%"
start "admin_web" /B pnpm dev
echo   admin_web 启动中...

REM 等待服务启动
echo.
echo [4/4] 等待服务启动...
timeout /t 8 >nul

echo.
echo ======================================
echo   服务启动完成!
echo ======================================
echo.
echo   admin_api:  http://localhost:%API_PORT%
echo   admin_web:  http://localhost:%WEB_PORT%
echo.
