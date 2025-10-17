# Nginx with QUIC/HTTP3 Support

[![Build and Push Nginx with QUIC](https://github.com/ZBaimo/Nginx-quic/actions/workflows/build.yml/badge.svg)](https://github.com/ZBaimo/Nginx-quic/actions/workflows/build.yml)
[![Docker Image](https://img.shields.io/badge/docker-ghcr.io-blue.svg)](https://github.com/ZBaimo/Nginx-quic/pkgs/container/nginx-quic)

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

从 GitHub Container Registry 拉取镜像：

```bash
docker pull ghcr.io/zbaimo/nginx-quic:latest
```

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
# 运行容器
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
  ghcr.io/zbaimo/nginx-quic:latest
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

- ✅ 每次推送到 `main` 分支时自动构建
- ✅ 每周一自动构建最新版本
- ✅ 支持手动触发构建
- ✅ 自动发布到 GitHub Container Registry
- ✅ 多架构构建（amd64, arm64）

查看构建状态：[Actions](https://github.com/ZBaimo/Nginx-quic/actions)

## 📝 开发

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

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📮 联系方式

- GitHub: [@ZBaimo](https://github.com/ZBaimo)
- Issues: [GitHub Issues](https://github.com/ZBaimo/Nginx-quic/issues)

---

⭐ 如果这个项目对你有帮助，请给个 Star！
