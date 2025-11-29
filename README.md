# Nginx with QUIC/HTTP3 Support

[![Build and Push Nginx with QUIC](https://github.com/ZBaimo/Nginx-quic/actions/workflows/build.yml/badge.svg)](https://github.com/ZBaimo/Nginx-quic/actions/workflows/build.yml)
[![GHCR Image](https://img.shields.io/badge/ghcr.io-nginx--quic-blue.svg)](https://github.com/ZBaimo/Nginx-quic/pkgs/container/nginx-quic)
[![Docker Hub](https://img.shields.io/badge/docker.io-nginx--quic-blue.svg)](https://hub.docker.com/r/您的用户名/nginx-quic)

这是一个支持 HTTP/3 (QUIC) 协议的 Nginx Docker 镜像项目，使用最新的 OpenSSL 3.x 版本编译，提供完整的 QUIC 和 HTTP/3 支持。

## ✨ 特性

- ✅ **HTTP/3 (QUIC) 支持** - 最新的 QUIC 协议
- ✅ **HTTP/2 支持** - 完整的 HTTP/2 实现
- ✅ **OpenSSL 3.3.2** - 支持 QUIC 的 OpenSSL
- ✅ **Nginx 1.27.2** - 最新稳定版本
- ✅ **多架构支持** - AMD64 和 ARM64
- ✅ **自动构建** - GitHub Actions 自动编译
- ✅ **精简配置** - 只包含核心功能和 QUIC
- ✅ **轻量级** - 基于 Alpine Linux

## 📦 快速开始

### 方式一：使用预构建镜像（推荐）

从 Docker Hub 或 GitHub Container Registry 拉取最新版本（多架构支持）：

```bash
# 方式 A: 从 Docker Hub 拉取（推荐，国内访问更快）
docker pull 您的用户名/nginx-quic:latest
docker run -d -p 80:80 -p 443:443 -p 443:443/udp 您的用户名/nginx-quic:latest

# 方式 B: 从 GitHub Container Registry 拉取
docker pull ghcr.io/zbaimo/nginx-quic:latest
docker run -d -p 80:80 -p 443:443 -p 443:443/udp ghcr.io/zbaimo/nginx-quic:latest
```

**支持的架构：**
- `linux/amd64` (x86_64)
- `linux/arm64` (aarch64)

Docker 会自动选择适合你系统的架构版本。
### 方式二：本地构建

```bash
# 克隆仓库
git clone https://github.com/ZBaimo/Nginx-quic.git
cd Nginx-quic

# 生成测试用的自签名证书
chmod +x generate-ssl.sh
./generate-ssl.sh

# 使用 Docker Compose 构建并运行
docker-compose up -d

# 或者使用 Docker 直接构建
docker build -t nginx-quic .
```

## 🚀 使用方法

### 使用 Docker Compose（推荐）

1. 创建 SSL 证书目录并生成证书：
```bash
./generate-ssl.sh
```

2. 启动服务：
```bash
docker-compose up -d
```

3. 查看日志：
```bash
docker-compose logs -f
```

4. 停止服务：
```bash
docker-compose down
```

### 使用 Docker 运行

```bash
# 使用 Docker Hub 镜像（推荐）
docker run -d \
  --name nginx-quic \
  -p 80:80 \
  -p 443:443 \
  -p 443:443/udp \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/default.conf:/etc/nginx/conf.d/default.conf:ro \
  -v $(pwd)/ssl:/etc/nginx/ssl:ro \
  您的用户名/nginx-quic:latest

# 或使用 GHCR 镜像
docker run -d \
  --name nginx-quic \
  -p 80:80 \
  -p 443:443 \
  -p 443:443/udp \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/default.conf:/etc/nginx/conf.d/default.conf:ro \
  -v $(pwd)/ssl:/etc/nginx/ssl:ro \
  ghcr.io/zbaimo/nginx-quic:latest
```

**可用的镜像标签：**
- `latest` - 最新稳定版本（推荐）
- `main` - 主分支最新构建
- `v1.0.0` - 特定版本（如果打了标签）
- `sha-xxxxxxx` - 特定提交的构建

## 🔧 配置说明

### 端口

- `80` - HTTP（自动重定向到 HTTPS）
- `443/tcp` - HTTPS (HTTP/1.1, HTTP/2)
- `443/udp` - HTTP/3 (QUIC)

### SSL 证书

默认配置期望证书位于以下位置：
- 证书：`/etc/nginx/ssl/cert.pem`
- 私钥：`/etc/nginx/ssl/key.pem`

#### 生产环境证书

推荐使用 Let's Encrypt：

```bash
# 使用 certbot 获取证书
certbot certonly --standalone -d yourdomain.com

# 将证书复制到 ssl 目录
cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ./ssl/cert.pem
cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ./ssl/key.pem
```

### 自定义配置

你可以挂载自己的配置文件：

```bash
docker run -d \
  -v $(pwd)/custom-nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/custom-site.conf:/etc/nginx/conf.d/default.conf:ro \
  您的用户名/nginx-quic:latest
```

## 🧪 验证 HTTP/3 支持

### 方法一：使用 curl（需要支持 HTTP/3 的版本）

```bash
# 检查 HTTP/3 连接
curl -I --http3 https://localhost

# 查看响应头
curl -v --http3 https://localhost
```

### 方法二：使用浏览器

1. 访问 `https://localhost`
2. 打开开发者工具 (F12)
3. 查看 Network 标签页
4. 检查 Protocol 列是否显示 `h3` 或 `http/3`

### 方法三：在线测试工具

- [HTTP/3 Check](https://http3check.net/)
- [Geek Flare HTTP/3 Test](https://geekflare.com/tools/http3-test)

## 📊 配置说明

该镜像包含：

- **自动工作进程** - 根据 CPU 核心数自动调整
- **QUIC 重试** - 提高连接可靠性
- **Early Data** - TLS 1.3 0-RTT 支持
- **Gzip 压缩** - 自动压缩文本内容
- **TCP 优化** - tcp_nopush 和 tcp_nodelay

## 🔨 编译选项

Nginx 编译时启用的核心模块：

- ✅ **HTTP/3 (QUIC)** - 最新的 HTTP 协议
- ✅ **HTTP/2** - HTTP/2 协议支持
- ✅ **SSL/TLS** - HTTPS 加密支持
- ✅ **Threads** - 多线程支持
- ✅ **Real IP** - 获取真实客户端 IP
- ✅ **Gzip** - 内容压缩
- ✅ **Stub Status** - 状态监控
- ✅ **基础 HTTP 模块** - 标准 HTTP 功能

## 🔄 自动构建

本项目使用 GitHub Actions 自动构建和发布 Docker 镜像：

- ✅ 推送到 `main` 分支 → 自动构建并标记为 `latest`
- ✅ 每周一自动构建最新版本
- ✅ 支持手动触发构建
- ✅ 自动发布到 GitHub Container Registry 和 Docker Hub
- ✅ 多架构构建（amd64, arm64）- Docker 自动选择合适架构
- ✅ 支持版本标签（如 v1.0.0）

**镜像地址：**
- Docker Hub: `您的用户名/nginx-quic:latest`
- GitHub Container Registry: `ghcr.io/zbaimo/nginx-quic:latest`

查看构建状态：[Actions](https://github.com/ZBaimo/Nginx-quic/actions)

## 📝 开发

### 更新 Nginx 和 QUIC 版本并重新编译

当 Nginx 或 OpenSSL（QUIC）发布新版本时，按照以下步骤更新和重新编译：

#### 📋 完整更新流程

**第 1 步：检查最新版本**

访问官方网站查看最新版本：
- **Nginx**: https://nginx.org/en/download.html
- **OpenSSL**: https://www.openssl.org/source/

示例版本：
- Nginx: `1.27.2` → `1.27.3`（新版本）
- OpenSSL: `3.3.2` → `3.4.0`（新版本）

**第 2 步：更新 Dockerfile**

编辑项目根目录的 `Dockerfile` 文件，修改第 5-6 行的版本号：

```dockerfile
# 在 Dockerfile 中找到这两行
ARG NGINX_VERSION=1.27.2      # 修改为 1.27.3
ARG OPENSSL_VERSION=3.3.2     # 修改为 3.4.0
```

**第 3 步：更新 GitHub Actions 配置（可选但推荐）**

编辑 `.github/workflows/build.yml` 文件，同步更新构建参数（第 83-84 行）：

```yaml
build-args: |
  NGINX_VERSION=1.27.3      # 与 Dockerfile 保持一致
  OPENSSL_VERSION=3.4.0     # 与 Dockerfile 保持一致
```

**第 4 步：本地测试构建**

在提交到 GitHub 之前，建议先在本地测试构建：

```bash
# 清理旧镜像（可选）
docker rmi nginx-quic:test

# 构建新版本
docker build -t nginx-quic:test .

# 测试运行
docker run -d --name test-nginx -p 8080:80 nginx-quic:test

# 验证版本
docker exec test-nginx nginx -v
# 应该显示: nginx version: nginx/1.27.3

# 清理测试容器
docker stop test-nginx && docker rm test-nginx
```

**第 5 步：提交更改**

```bash
# 查看修改
git diff

# 添加修改的文件
git add Dockerfile .github/workflows/build.yml

# 提交更改
git commit -m "chore: 更新 Nginx 到 1.27.3 和 OpenSSL 到 3.4.0"

# 推送到 GitHub
git push origin main
```

**第 6 步：自动构建**

推送后，GitHub Actions 会自动：
1. ✅ 构建多架构镜像（amd64, arm64）
2. ✅ 推送到 Docker Hub
3. ✅ 推送到 GitHub Container Registry
4. ✅ 打上 `latest` 标签

查看构建进度：https://github.com/ZBaimo/Nginx-quic/actions

#### 🚀 快速更新方法

**方式一：仅更新 Dockerfile（自动构建）**

Linux/macOS:
```bash
# 修改 Dockerfile 中的版本号
sed -i 's/NGINX_VERSION=1.27.2/NGINX_VERSION=1.27.3/' Dockerfile
sed -i 's/OPENSSL_VERSION=3.3.2/OPENSSL_VERSION=3.4.0/' Dockerfile

# 提交并推送
git add Dockerfile
git commit -m "chore: 更新版本"
git push
```

Windows PowerShell:
```powershell
# 修改 Dockerfile 中的版本号
(Get-Content Dockerfile) -replace 'NGINX_VERSION=1.27.2','NGINX_VERSION=1.27.3' | Set-Content Dockerfile
(Get-Content Dockerfile) -replace 'OPENSSL_VERSION=3.3.2','OPENSSL_VERSION=3.4.0' | Set-Content Dockerfile

# 提交并推送
git add Dockerfile
git commit -m "chore: 更新版本"
git push
```

**方式二：本地直接构建指定版本（跳过修改文件）**

```bash
docker build \
  --build-arg NGINX_VERSION=1.27.3 \
  --build-arg OPENSSL_VERSION=3.4.0 \
  -t nginx-quic:custom \
  --progress=plain \
  .
```

**方式三：使用 Docker Compose 构建**

修改 `docker-compose.yml`（如果需要）：

```yaml
services:
  nginx-quic:
    build:
      context: .
      args:
        NGINX_VERSION: 1.27.3
        OPENSSL_VERSION: 3.4.0
```

然后构建：
```bash
docker-compose build --no-cache
```

#### 🔍 版本验证

构建完成后，验证新版本：

```bash
# 检查 Nginx 版本
docker run --rm 您的用户名/nginx-quic:latest nginx -v

# 检查 OpenSSL 版本
docker run --rm 您的用户名/nginx-quic:latest nginx -V 2>&1 | grep -i openssl

# 检查 HTTP/3 支持
docker run --rm 您的用户名/nginx-quic:latest nginx -V 2>&1 | grep -i http_v3
```

#### 📝 版本更新记录示例

建议在 README 中维护版本更新历史：

| 日期 | Nginx 版本 | OpenSSL 版本 | 说明 |
|------|------------|--------------|------|
| 2025-11-29 | 1.28.0 | 3.6.0 | v.1.0.2 |
| 2024-10-17 | 1.27.3 | 3.4.0 | v.1.0.1|
| 2024-09-15 | 1.27.2 | 3.3.2 | v.1.0.0 |

#### ⚠️ 注意事项

1. **兼容性检查**：更新前查看 [Nginx 变更日志](https://nginx.org/en/CHANGES) 确认没有破坏性更改
2. **OpenSSL 要求**：确保 OpenSSL 版本支持 QUIC（3.0.0+）
3. **测试验证**：重大版本更新前务必先在本地或测试环境验证
4. **回滚准备**：保留上一个稳定版本的镜像标签，便于快速回滚
5. **构建时间**：完整构建需要 10-20 分钟，取决于服务器性能

#### 📌 版本来源

- **Nginx 最新版本**: https://nginx.org/en/download.html
- **OpenSSL 最新版本**: https://www.openssl.org/source/
- **Nginx QUIC 文档**: https://nginx.org/en/docs/quic.html

### 构建参数

可以通过构建参数自定义版本：

```bash
docker build \
  --build-arg NGINX_VERSION=1.27.2 \
  --build-arg OPENSSL_VERSION=3.3.2 \
  -t nginx-quic:custom .
```

### 本地测试

```bash
# 构建镜像
docker-compose build

# 运行测试
docker-compose up -d

# 查看日志
docker-compose logs -f

# 清理
docker-compose down -v
```

## 🐛 故障排除

### 问题：无法启动容器

检查日志：
```bash
docker logs nginx-quic
```

### 问题：SSL 证书错误

确保 SSL 证书文件存在且权限正确：
```bash
ls -la ./ssl/
# 应该看到 cert.pem 和 key.pem
```

### 问题：无法访问 HTTP/3

1. 确保防火墙允许 UDP 443 端口
2. 检查浏览器是否支持 HTTP/3
3. 验证证书是否有效

## 📚 参考资料

- [Nginx 官方文档](https://nginx.org/en/docs/)
- [Nginx QUIC 支持](https://nginx.org/en/docs/quic.html)
- [HTTP/3 explained](https://http3-explained.haxx.se/)
- [OpenSSL 文档](https://www.openssl.org/docs/)

## 📊 版本历史

当前版本和历史更新记录：

| 日期 | Nginx 版本 | OpenSSL 版本 | 更新说明 |
|------|------------|--------------|----------|
| 2024-10-17 | 1.27.2 | 3.3.2 | 初始版本，支持 HTTP/3 (QUIC) |

**当前构建配置：**
- Nginx: `1.27.2` ([变更日志](https://nginx.org/en/CHANGES))
- OpenSSL: `3.3.2` ([变更日志](https://www.openssl.org/news/changelog.html))
- 支持协议: HTTP/1.1, HTTP/2, HTTP/3 (QUIC)
- 构建平台: linux/amd64, linux/arm64

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

如何贡献：
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

## 📮 联系方式

- GitHub: [@ZBaimo](https://github.com/ZBaimo)
- Issues: [GitHub Issues](https://github.com/ZBaimo/Nginx-quic/issues)

---

⭐ 如果这个项目对你有帮助，请给个 Star！
