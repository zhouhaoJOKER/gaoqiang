#!/usr/bin/env bash

# start_gaoqiang.sh
# 快速启动 admin_api (Rails) 和 admin_web (Vite/Vue3)
# Git Bash 版本 - 动态检测启动状态

set -e

PROJECT_ROOT="/d/project/github/gaoqiang"
API_DIR="$PROJECT_ROOT/admin_api"
WEB_DIR="$PROJECT_ROOT/admin_web"
API_PORT=3000
WEB_PORT=5173

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}======================================${NC}"
echo -e "${CYAN}  启动 gaoqiang 项目开发环境${NC}"
echo -e "${CYAN}======================================${NC}"
echo ""

# 函数：检查端口是否被监听
check_port_listening() {
    local port=$1
    netstat -ano 2>/dev/null | grep -q ":$port " && \
    netstat -ano 2>/dev/null | grep ":$port " | grep -q LISTENING
    return $?
}

# 函数：获取监听端口的 PID
get_port_pid() {
    local port=$1
    netstat -ano 2>/dev/null | grep ":$port " | grep LISTENING | awk '{print $NF}' | head -1
}

# 步骤 1: 检查并清理端口
echo -e "${CYAN}[1/4] 检查端口占用情况...${NC}"

for port in $API_PORT $WEB_PORT; do
    pid=$(get_port_pid $port)
    if [ -n "$pid" ]; then
        echo -e "${YELLOW}  端口 $port 被占用 (PID: $pid)，正在清理...${NC}"
        taskkill /F /PID $pid 2>/dev/null || true
        sleep 1
    else
        echo -e "  ${GREEN}端口 $port 可用${NC}"
    fi
done

echo ""

# 步骤 2 & 3: 并行启动服务
echo -e "${CYAN}[2/4] 启动 admin_api (Rails)...${NC}"
echo -e "${CYAN}[3/4] 启动 admin_web (Vite)...${NC}"

# 启动 Rails API
cd "$API_DIR"
bin/rails server -p $API_PORT &
API_PID=$!
api_start_time=$(date +%s)

# 启动 Vite 前端
cd "$WEB_DIR"
pnpm dev &
WEB_PID=$!
web_start_time=$(date +%s)

echo ""

# 步骤 4: 动态检测启动状态
echo -e "${CYAN}[4/4] 等待服务启动...${NC}"

api_ready=false
web_ready=false
max_wait=30

for i in $(seq 1 $max_wait); do
    sleep 1

    # 检测 Rails API
    if [ "$api_ready" = false ] && check_port_listening $API_PORT; then
        api_elapsed=$(( $(date +%s) - api_start_time ))
        echo -e "  ${GREEN}✓ admin_api 已就绪 (耗时：${api_elapsed}秒)${NC}"
        api_ready=true
    fi

    # 检测 Vite 前端
    if [ "$web_ready" = false ] && check_port_listening $WEB_PORT; then
        web_elapsed=$(( $(date +%s) - web_start_time ))
        echo -e "  ${GREEN}✓ admin_web 已就绪 (耗时：${web_elapsed}秒)${NC}"
        web_ready=true
    fi

    # 两个都就绪就退出
    if [ "$api_ready" = true ] && [ "$web_ready" = true ]; then
        break
    fi
done

# 超时警告
if [ "$api_ready" = false ]; then
    echo -e "${YELLOW}  ⚠ admin_api 启动超时${NC}"
fi
if [ "$web_ready" = false ]; then
    echo -e "${YELLOW}  ⚠ admin_web 启动超时${NC}"
fi

echo ""
echo -e "${CYAN}======================================${NC}"
echo -e "${CYAN}  服务启动完成!${NC}"
echo -e "${CYAN}======================================${NC}"
echo ""
echo -e "${GREEN}  ✓ admin_api:  http://localhost:$API_PORT${NC}"
echo -e "${GREEN}  ✓ admin_web:  http://localhost:$WEB_PORT${NC}"
echo ""
echo -e "  进程 ID: admin_api=$API_PID, admin_web=$WEB_PID"
echo -e "  提示：按 Ctrl+C 或运行 kill $API_PID $WEB_PID 可停止服务"
echo ""

# 保持脚本运行，等待用户中断
wait
