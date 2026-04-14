---
name: start_gaoqiang
description: 启动 admin_api (Rails) 和 admin_web (Vite/Vue3) 两个开发服务 - Windows 版本
version: 2.0.0
allowed-tools: [Bash]
---

# start_gaoqiang - 项目启动技能 (Windows)

快速启动 admin_api (Rails API 后端) 和 admin_web (Vite/Vue3 前端) 两个开发服务。

**运行环境**: Windows 11

## 使用方法

```
/start_gaoqiang
```

## 执行流程

### 第一步：检查端口占用

检查端口 3000 (admin_api) 和 5173 (admin_web) 是否被占用。

```bash
netstat -ano | findstr ":3000 "
netstat -ano | findstr ":5173 "
```

### 第二步：清理旧进程 (PowerShell)

使用 PowerShell 终止占用端口的进程：

```powershell
Get-Process -Id <PID> -ErrorAction SilentlyContinue | Stop-Process -Force
```

### 第三步：启动服务

使用 `run_in_background: true` 在后台分别启动：

```bash
# 启动 admin_api (Git Bash 语法)
cd /d/project/github/gaoqiang/admin_api && bin/rails server -p 3000

# 启动 admin_web  
cd /d/project/github/gaoqiang/admin_web && pnpm dev
```

### 第四步：验证启动

等待 8-10 秒后检查日志输出，确认服务正常启动。

Rails 启动成功的标志：
```
* Listening on http://127.0.0.1:3000
```

Vite 启动成功的标志：
```
Local:   http://localhost:5173/
```

### 第五步：输出结果

显示服务地址：
- **admin_api**: http://localhost:3000
- **admin_web**: http://localhost:5173

## 注意事项

1. **端口清理**: Windows 上 `taskkill /F /PID xxx` 可能在 Bash 中语法有问题，优先使用 PowerShell 的 `Stop-Process`
2. **路径格式**: Git Bash 中使用 `/d/...` 格式的 Windows 路径
3. **后台进程**: 使用 `run_in_background: true` 参数启动后台服务
4. **启动时间**: Rails 服务器通常需要 5-10 秒完全启动

## 手动启动方式

也可以直接在两个终端窗口中运行：

```cmd
REM 终端 1 - 启动 API
cd /d D:\project\github\gaoqiang\admin_api
bin\rails server -p 3000

REM 终端 2 - 启动 Web
cd /d D:\project\github\gaoqiang\admin_web
pnpm dev
```

## 相关项目

- `admin_api/` - Rails 8.0 API 后端
- `admin_web/` - Vite + Vue3 前端
