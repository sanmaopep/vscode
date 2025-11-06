# VSCode Web 快速部署指南

本指南提供了部署 VSCode 网页版的最简单方法。

## 快速开始（推荐）

### 方式一：使用启动脚本（最简单）

```bash
# 1. 运行快速启动脚本
./start-vscode-web.sh

# 2. 自定义主机和端口
./start-vscode-web.sh --host 0.0.0.0 --port 3000
```

脚本会自动：
- 检查 Node.js 和 npm 版本
- 安装依赖（如果尚未安装）
- 编译项目（如果尚未编译）
- 启动 Web 服务器

访问：`http://localhost:8080`

---

### 方式二：手动步骤

```bash
# 1. 安装依赖
npm install

# 2. 编译 Web 版本
npm run compile-web

# 3. 启动服务器
node ./scripts/code-web.js --host 0.0.0.0 --port 8080
```

---

### 方式三：使用 Docker（推荐用于生产环境）

#### 开发模式：
```bash
docker-compose --profile dev up
```
访问：`http://localhost:8080`

#### 生产模式：
```bash
docker-compose --profile prod up
```
访问：`http://localhost`

---

## 环境要求

- **Node.js**: >= 18.x
- **npm**: >= 8.x
- **内存**: >= 4GB RAM（推荐 8GB）
- **磁盘空间**: >= 5GB

---

## 常用命令

| 命令 | 说明 |
|------|------|
| `npm install` | 安装依赖 |
| `npm run compile-web` | 编译 Web 版本 |
| `npm run watch-web` | 监听模式（自动重新编译） |
| `./scripts/code-web.sh` | 启动开发服务器（Linux/Mac） |
| `node ./scripts/code-web.js` | 启动开发服务器（通用） |

---

## 命令行参数

启动服务器时可以使用以下参数：

```bash
node ./scripts/code-web.js \
  --host 0.0.0.0 \              # 监听地址（默认: localhost）
  --port 8080 \                 # 端口号（默认: 8080）
  --extensionPath ./extensions \# 扩展路径
  --playground                  # 包含 playground 扩展
```

或使用环境变量：

```bash
export VSCODE_WEB_HOST=0.0.0.0
export VSCODE_WEB_PORT=3000
./start-vscode-web.sh
```

---

## 部署到生产环境

### 使用 Docker（推荐）

```bash
# 构建生产镜像
docker build -t vscode-web:latest .

# 运行容器
docker run -d \
  --name vscode-web \
  -p 80:80 \
  vscode-web:latest
```

### 使用 Nginx

1. 构建生产版本：
```bash
npm install
npm run gulp compile-build
npm run gulp minify-vscode-web
```

2. 部署到 Nginx：
```bash
cp -r out-vscode-web-min/* /usr/share/nginx/html/vscode-web/
cp nginx.conf /etc/nginx/sites-available/vscode-web
```

3. 启动 Nginx：
```bash
nginx -t
systemctl restart nginx
```

---

## 故障排除

### 问题 1: 端口已被占用

```bash
# 查找占用端口的进程
lsof -i :8080
# 或使用其他端口
node ./scripts/code-web.js --port 3000
```

### 问题 2: 依赖安装失败

```bash
# 清理缓存并重新安装
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

### 问题 3: 编译速度慢

```bash
# 使用更多 CPU 核心
export UV_THREADPOOL_SIZE=8
npm run compile-web
```

### 问题 4: 内存不足

```bash
# 增加 Node.js 内存限制
export NODE_OPTIONS="--max-old-space-size=8192"
npm run compile-web
```

---

## 完整部署文档

详细的部署指南请参阅：[DEPLOYMENT.md](./DEPLOYMENT.md)

包含内容：
- 多种部署方式详解
- Docker Compose 配置
- Nginx 配置说明
- 性能优化建议
- 安全配置指南
- 监控和日志管理

---

## 文件说明

| 文件 | 说明 |
|------|------|
| `start-vscode-web.sh` | 快速启动脚本（自动化所有步骤） |
| `Dockerfile` | 生产环境 Docker 配置 |
| `Dockerfile.dev` | 开发环境 Docker 配置 |
| `docker-compose.yml` | Docker Compose 配置 |
| `nginx.conf` | Nginx 配置文件 |
| `DEPLOYMENT.md` | 完整部署文档 |

---

## 下一步

1. ✅ **快速测试**：运行 `./start-vscode-web.sh` 在本地测试
2. ✅ **开发调试**：使用 `npm run watch-web` 进行开发
3. ✅ **生产部署**：使用 Docker 或手动部署到服务器
4. ✅ **配置 HTTPS**：为生产环境配置 SSL 证书
5. ✅ **添加认证**：配置 OAuth 或其他认证方式

---

## 技术支持

- [VSCode 官方文档](https://code.visualstudio.com/docs)
- [GitHub Issues](https://github.com/microsoft/vscode/issues)
- [完整部署文档](./DEPLOYMENT.md)

---

## 许可证

遵循 VSCode 的 MIT 许可证
