---
name: start_gaoqiang
description: 快速启动 admin_api (Rails) 和 admin_web (Vite/Vue3) 两个开发服务 - Windows 版本。优先使用动态检测而非固定等待，最大化启动速度。
version: 3.0.0
allowed-tools: [Bash]
---

# start_gaoqiang - 项目启动技能 (Windows 高速版)

快速启动 admin_api (Rails API 后端) 和 admin_web (Vite/Vue3 前端) 两个开发服务。

**运行环境**: Windows 11

**优化目标**: 最小化启动等待时间，使用动态检测替代固定延迟

## 执行流程

### 第一步：检查并清理端口 (并行执行)

同时检查两个端口并清理占用进程：

```bash
# 并行检查端口 3000 和 5173
netstat -ano | findstr ":3000 :5173 "
```

如果端口被占用，使用 PowerShell 清理：

```powershell
# 获取 PID 并终止进程
Get-Process -Id <PID> -ErrorAction SilentlyContinue | Stop-Process -Force
```

### 第二步：并行启动服务

使用 `run_in_background: true` 同时启动两个服务：

```bash
# 启动 admin_api (Rails)
cd /d/project/github/gaoqiang/admin_api && bin/rails server -p 3000

# 启动 admin_web (Vite/Vue3) - 禁用自动打开浏览器
cd /d/project/github/gaoqiang/admin_web && pnpm dev
```

**注意**: Vite 的 `--open` 参数在后台运行时可能失败，如遇到问题可改为 `vite` 直接运行。

### 第三步：动态检测启动状态

**不要使用固定的 sleep 等待！** 使用轮询检测：

```bash
# 检测 Vite (通常 2-5 秒)
# 轮询检查端口 5173 或日志输出
# 一旦检测到 "Local:" 或 "ready in" 立即继续

# 检测 Rails (通常 8-12 秒)
# 轮询检查端口 3000 或日志输出  
# 一旦检测到 "Listening on" 立即继续
```

轮询策略：
- 每 1 秒检查一次
- Vite 最多等待 10 秒
- Rails 最多等待 20 秒
- 两个检测并行执行

### 第四步：输出结果

显示服务地址和启动时间：

```
✓ admin_web:  http://localhost:5173 (启动耗时: X 秒)
✓ admin_api:  http://localhost:3000 (启动耗时: Y 秒)
```

## 优化要点

1. **并行检测** - 两个服务的启动检测同时进行，不互相阻塞
2. **动态轮询** - 每 1 秒检查一次，就绪立即返回，避免固定等待浪费时间
3. **早停策略** - 单个服务启动成功后不再等待该服务
4. **超时保护** - 最长等待时间作为保护，不阻塞正常流程

## 快速检测命令

```bash
# 检查端口是否被监听
netstat -ano | findstr ":3000 :5173 "

# 检查进程是否运行
Get-Process | Where-Object { $_.ProcessName -match "ruby|node" }

# 检查 Rails 日志
# 读取后台任务输出文件，查找 "Listening on"

# 检查 Vite 日志
# 读取后台任务输出文件，查找 "Local:" 或 "ready in"
```

## 常见问题

**Q: 端口被占用怎么办？**
A: 使用 PowerShell 终止占用进程：`Get-Process -Id <PID> | Stop-Process -Force`

**Q: Rails 启动超过 20 秒？**
A: 检查是否有 bundle install 或 migration 在运行，首次启动可能较慢

**Q: Vite 自动打开浏览器失败？**
A: 后台模式下 `--open` 可能失败，这是正常的，浏览器可以手动访问 localhost:5173

## 相关项目

- `admin_api/` - Rails 8.0 API 后端
- `admin_web/` - Vite + Vue3 前端
