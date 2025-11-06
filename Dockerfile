# VSCode Web 生产环境 Dockerfile
# 多阶段构建：构建阶段 + Nginx 服务阶段

# ===== 构建阶段 =====
FROM node:18-bullseye AS builder

# 安装构建依赖
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    make \
    g++ \
    pkg-config \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    libkrb5-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# 复制依赖配置文件
COPY package.json package-lock.json* ./
COPY remote/package.json ./remote/
COPY remote/web/package.json ./remote/web/

# 安装依赖
RUN npm ci

# 复制源代码
COPY . .

# 下载内置扩展
RUN npm run download-builtin-extensions

# 编译和打包 Web 版本
RUN npm run gulp compile-build
RUN npm run gulp minify-vscode-web

# ===== 运行阶段 =====
FROM nginx:alpine

# 安装 Node.js (用于运行 VSCode Web 服务器)
RUN apk add --no-cache nodejs npm

# 从构建阶段复制构建产物
COPY --from=builder /build/out-vscode-web-min/ /usr/share/nginx/html/vscode-web/

# 复制 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]
