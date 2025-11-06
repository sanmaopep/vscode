#!/bin/bash
# VSCode Web 快速启动脚本
# 用于在完整环境中快速启动 VSCode Web 服务器

set -e

echo "========================================="
echo " VSCode Web 快速启动脚本"
echo "========================================="
echo ""

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "错误：未找到 Node.js，请先安装 Node.js >= 18.x"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "警告：Node.js 版本过低（当前: $(node --version)），推荐版本 >= 18.x"
fi

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo "错误：未找到 npm"
    exit 1
fi

echo "✓ Node.js 版本: $(node --version)"
echo "✓ npm 版本: $(npm --version)"
echo ""

# 检查依赖是否已安装
if [ ! -d "node_modules" ]; then
    echo "正在安装依赖... (这可能需要几分钟)"
    npm install
    echo "✓ 依赖安装完成"
    echo ""
else
    echo "✓ 依赖已安装"
    echo ""
fi

# 检查是否已编译
if [ ! -d "out" ]; then
    echo "正在编译 VSCode Web... (这可能需要几分钟)"
    npm run compile-web
    echo "✓ 编译完成"
    echo ""
else
    echo "✓ 已编译（如需重新编译，请运行: npm run compile-web）"
    echo ""
fi

# 解析命令行参数
HOST="${VSCode_WEB_HOST:-0.0.0.0}"
PORT="${VSCODE_WEB_PORT:-8080}"

while [[ $# -gt 0 ]]; do
    case $1 in
        --host)
            HOST="$2"
            shift 2
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        *)
            echo "未知参数: $1"
            echo "用法: $0 [--host HOST] [--port PORT]"
            exit 1
            ;;
    esac
done

echo "========================================="
echo " 正在启动 VSCode Web 服务器..."
echo " 主机: $HOST"
echo " 端口: $PORT"
echo "========================================="
echo ""
echo "访问地址: http://localhost:$PORT"
echo ""
echo "按 Ctrl+C 停止服务器"
echo ""

# 启动服务器
exec node ./scripts/code-web.js --host "$HOST" --port "$PORT"
