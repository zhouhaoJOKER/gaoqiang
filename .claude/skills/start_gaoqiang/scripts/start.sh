#!/usr/bin/env bash

# start_gaoqiang.sh
# 启动 admin_api 和 admin_web 两个项目的开发服务

set -e

PROJECT_ROOT="/d/project/github/gaoqiang"
API_DIR="$PROJECT_ROOT/admin_api"
WEB_DIR="$PROJECT_ROOT/admin_web"
API_PORT=3000
WEB_PORT=5173

echo "======================================"
echo "  启动 gaoqiang 项目开发环境"
echo "======================================"

# 函数：检查端口是否被占用
check_port() {
    local port=$1
    if netstat -ano 2>/dev/null | grep -q ":$port "; then
        return 0  # 端口被占用
    fi
    return 1  # 端口空闲
}

# 函数：杀掉占用端口的进程
kill_port_process() {
    local port=$1
    local pid=$(netstat -ano 2>/dev/null | grep ":$port " | grep LISTENING | awk '{print $NF}')
    if [ -n "$pid" ]; then
        echo "  发现进程占用端口 $port (PID: $pid)，正在终止..."
        taskkill /F /PID $pid 2>/dev/null || true
        sleep 2
    fi
}

# 检查并清理端口
echo ""
echo "[1/4] 检查端口占用情况..."

if check_port $API_PORT; then
    echo "  端口 $API_PORT 已被占用，正在清理..."
    kill_port_process $API_PORT
else
    echo "  端口 $API_PORT 可用"
fi

if check_port $WEB_PORT; then
    echo "  端口 $WEB_PORT 已被占用，正在清理..."
    kill_port_process $WEB_PORT
else
    echo "  端口 $WEB_PORT 可用"
fi

# 启动服务
echo ""
echo "[2/4] 启动 admin_api (Rails)..."
cd "$API_DIR"
nohup bin/rails server -p $API_PORT > /tmp/admin_api.log 2>&1 &
API_PID=$!
echo "  admin_api 已启动 (PID: $API_PID)"

echo ""
echo "[3/4] 启动 admin_web (Vite)..."
cd "$WEB_DIR"
nohup pnpm dev > /tmp/admin_web.log 2>&1 &
WEB_PID=$!
echo "  admin_web 已启动 (PID: $WEB_PID)"

# 等待服务启动
echo ""
echo "[4/4] 等待服务启动..."
sleep 8

# 验证服务
echo ""
echo "======================================"
echo "  服务启动完成!"
echo "======================================"
echo ""
echo "  admin_api:  http://localhost:$API_PORT"
echo "  admin_web:  http://localhost:$WEB_PORT"
echo ""
echo "  如需停止服务:"
echo "    kill $API_PID  # 停止 admin_api"
echo "    kill $WEB_PID  # 停止 admin_web"
echo ""
