---
name: environment
description: 项目在 Windows 11 上运行，使用 Ruby 3.4 和 pnpm
type: project
---

## 运行环境

- **操作系统**: Windows 11 Enterprise LTSC 2024 (10.0.26100)
- **Ruby 版本**: 3.4.x (C:/Ruby34-x64/)
- **前端包管理器**: pnpm
- **数据库**: MySQL 8.4

## 端口占用清理方式

Windows 上使用 PowerShell 清理端口：
```powershell
Get-Process -Id <PID> -ErrorAction SilentlyContinue | Stop-Process -Force
```

或使用 netstat + taskkill 组合：
```cmd
for /f "tokens=5" %a in ('netstat -ano ^| findstr ":3000 " ^| findstr LISTENING') do @taskkill /F /PID %a
```

## 后台进程启动

Windows 上使用 `start "" /B` 启动后台进程：
```cmd
start "admin_api" /B bin\rails server -p 3000
start "admin_web" /B pnpm dev
```
