# VSCode Web 部署指南

本指南提供了部署 VSCode Web 版本的完整说明，支持多种部署方式。

## 目录

- [快速开始](#快速开始)
- [部署方式](#部署方式)
  - [1. 本地开发模式](#1-本地开发模式)
  - [2. Docker 开发模式](#2-docker-开发模式)
  - [3. Docker 生产模式](#3-docker-生产模式)
  - [4. 手动构建部署](#4-手动构建部署)
- [配置说明](#配置说明)
- [常见问题](#常见问题)

---

## 快速开始

### 前置要求

- **Node.js**: >= 18.x
- **Yarn**: >= 1.22.x
- **Docker**: >= 20.x (如果使用 Docker 部署)
- **Docker Compose**: >= 2.x (如果使用 Docker Compose)

### 最快速启动

```bash
# 方式 1: 使用内置脚本（推荐用于开发）
./scripts/code-web.sh

# 方式 2: 使用 Docker Compose（推荐用于测试）
docker-compose --profile dev up

# 方式 3: 使用 Docker Compose 生产模式
docker-compose --profile prod up
```

访问 `http://localhost:8080` (开发模式) 或 `http://localhost` (生产模式)

---

## 部署方式

### 1. 本地开发模式

适用于本地开发和调试。

#### 步骤：

1. **安装依赖**

```bash
yarn install
```

2. **下载内置扩展**

```bash
yarn download-builtin-extensions
```

3. **编译 Web 版本**

```bash
yarn compile-web
```

或使用监听模式（自动重新编译）：

```bash
yarn watch-web
```

4. **启动开发服务器**

```bash
# Linux/macOS
./scripts/code-web.sh

# Windows
scripts\code-web.bat

# 或直接使用 Node.js
node ./scripts/code-web.js --host 0.0.0.0 --port 8080
```

5. **访问应用**

打开浏览器访问：`http://localhost:8080`

#### 可用参数：

```bash
node ./scripts/code-web.js \
  --host 0.0.0.0 \           # 监听地址（默认: localhost）
  --port 8080 \              # 端口号（默认: 8080）
  --extensionPath ./extensions \  # 扩展路径
  --playground               # 包含 web-playground 扩展
```

---

### 2. Docker 开发模式

适用于需要隔离环境的开发场景。

#### 使用 Docker Compose：

```bash
# 启动开发环境
docker-compose --profile dev up

# 后台运行
docker-compose --profile dev up -d

# 查看日志
docker-compose logs -f vscode-web-dev

# 停止
docker-compose --profile dev down
```

#### 手动使用 Docker：

```bash
# 构建镜像
docker build -f Dockerfile.dev -t vscode-web-dev .

# 运行容器
docker run -d \
  --name vscode-web-dev \
  -p 8080:8080 \
  -v $(pwd)/src:/workspace/vscode/src \
  -v $(pwd)/extensions:/workspace/vscode/extensions \
  vscode-web-dev

# 查看日志
docker logs -f vscode-web-dev

# 停止容器
docker stop vscode-web-dev
docker rm vscode-web-dev
```

访问：`http://localhost:8080`

---

### 3. Docker 生产模式

适用于生产环境部署，使用 Nginx 提供静态文件服务。

#### 使用 Docker Compose：

```bash
# 构建并启动
docker-compose --profile prod up -d

# 查看日志
docker-compose logs -f vscode-web-prod

# 停止
docker-compose --profile prod down
```

#### 手动使用 Docker：

```bash
# 构建生产镜像
docker build -t vscode-web-prod .

# 运行容器
docker run -d \
  --name vscode-web-prod \
  -p 80:80 \
  -p 443:443 \
  vscode-web-prod

# 查看日志
docker logs -f vscode-web-prod

# 停止容器
docker stop vscode-web-prod
docker rm vscode-web-prod
```

访问：`http://localhost`

#### 健康检查：

```bash
# 检查容器健康状态
docker ps

# 手动健康检查
curl http://localhost/
```

---

### 4. 手动构建部署

适用于自定义部署环境。

#### 步骤：

1. **安装依赖**

```bash
yarn install --frozen-lockfile
```

2. **下载内置扩展**

```bash
yarn download-builtin-extensions
```

3. **构建生产版本**

```bash
# 编译构建
yarn gulp compile-build

# 最小化打包
yarn gulp minify-vscode-web
```

构建产物位于：`out-vscode-web-min/`

4. **部署到 Web 服务器**

将 `out-vscode-web-min/` 目录部署到任何静态文件服务器：

- **Nginx**: 复制到 `/usr/share/nginx/html/vscode-web/`
- **Apache**: 复制到 `/var/www/html/vscode-web/`
- **Caddy**: 使用提供的 Caddyfile
- **其他**: 任何能服务静态文件的 Web 服务器

5. **配置 Web 服务器**

参考提供的 `nginx.conf` 配置文件。

---

## 配置说明

### Nginx 配置

`nginx.conf` 文件包含了推荐的配置：

- **Gzip 压缩**: 减少传输大小
- **缓存策略**: 静态资源长期缓存，HTML 禁用缓存
- **安全头部**: X-Frame-Options, X-Content-Type-Options 等
- **WebSocket 支持**: 如果需要 WebSocket 连接
- **SPA 路由**: 所有路由回退到 index.html

### 环境变量

可以通过环境变量自定义配置：

```bash
# 设置 Node 环境
export NODE_ENV=production

# 设置端口（开发模式）
export PORT=8080

# 设置主机（开发模式）
export HOST=0.0.0.0
```

### Docker Compose 配置

`docker-compose.yml` 支持两个 profile：

- **dev**: 开发环境（端口 8080）
- **prod**: 生产环境（端口 80/443）

自定义配置：

```yaml
# 修改端口映射
ports:
  - "3000:8080"  # 将容器的 8080 映射到主机的 3000

# 添加环境变量
environment:
  - NODE_ENV=production
  - CUSTOM_VAR=value

# 挂载自定义配置
volumes:
  - ./custom-nginx.conf:/etc/nginx/conf.d/default.conf
```

---

## 性能优化

### 1. 启用 HTTP/2

在 Nginx 配置中启用 HTTP/2：

```nginx
listen 443 ssl http2;
```

### 2. 启用 Brotli 压缩

安装 Nginx Brotli 模块并配置：

```nginx
brotli on;
brotli_comp_level 6;
brotli_types text/plain text/css application/json application/javascript;
```

### 3. 配置 CDN

将静态资源部署到 CDN（如 Cloudflare, AWS CloudFront）：

```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    add_header Access-Control-Allow-Origin "*";
    expires 1y;
}
```

### 4. 预加载关键资源

在 HTML 中添加预加载标签：

```html
<link rel="preload" href="/out/vs/loader.js" as="script">
<link rel="preload" href="/out/vs/workbench/workbench.web.main.css" as="style">
```

---

## 常见问题

### 1. 启动失败：端口已被占用

```bash
# 查找占用端口的进程
lsof -i :8080

# 或使用其他端口
node ./scripts/code-web.js --port 3000
```

### 2. Docker 构建失败：内存不足

```bash
# 增加 Docker 内存限制
docker build --memory=4g -t vscode-web-prod .
```

### 3. 编译速度慢

```bash
# 使用更多 CPU 核心
export UV_THREADPOOL_SIZE=8
yarn compile-web
```

### 4. 浏览器无法访问

检查防火墙设置：

```bash
# Linux (ufw)
sudo ufw allow 8080

# Linux (iptables)
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
```

### 5. WebSocket 连接失败

确保 Nginx 配置了 WebSocket 支持（参见 `nginx.conf` 中的 `/ws` location）。

### 6. 静态资源 404

检查文件路径和 Nginx 配置中的 `root` 指令。

---

## 安全建议

1. **HTTPS**: 在生产环境中始终使用 HTTPS
2. **认证**: 添加身份验证（Nginx Basic Auth, OAuth, etc.）
3. **CORS**: 配置适当的 CORS 策略
4. **CSP**: 配置内容安全策略（Content Security Policy）
5. **限流**: 配置速率限制防止滥用

示例 Nginx 认证配置：

```nginx
location / {
    auth_basic "VSCode Web";
    auth_basic_user_file /etc/nginx/.htpasswd;
    try_files $uri $uri/ /index.html;
}
```

---

## 监控和日志

### 查看日志

**Docker 日志：**
```bash
docker logs -f vscode-web-prod
```

**Nginx 日志：**
```bash
tail -f /var/log/nginx/vscode-web-access.log
tail -f /var/log/nginx/vscode-web-error.log
```

### 监控指标

建议监控以下指标：

- CPU 使用率
- 内存使用率
- 网络流量
- 响应时间
- 错误率

可以使用 Prometheus + Grafana 进行监控。

---

## 升级和维护

### 更新代码

```bash
# 拉取最新代码
git pull origin main

# 重新安装依赖
yarn install

# 重新构建
yarn compile-web

# 重启服务
docker-compose --profile prod restart
```

### 备份

建议定期备份：

- 用户数据
- 扩展配置
- Nginx 配置
- SSL 证书

---

## 支持和反馈

如遇到问题，请查阅：

- [VSCode 官方文档](https://code.visualstudio.com/docs)
- [GitHub Issues](https://github.com/microsoft/vscode/issues)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/vscode)

---

## 许可证

请遵循 VSCode 的 MIT 许可证。
