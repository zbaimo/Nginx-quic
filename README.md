# Nginx with QUIC/HTTP3 Support

[![Build and Push Nginx with QUIC](https://github.com/ZBaimo/Nginx-quic/actions/workflows/build.yml/badge.svg)](https://github.com/ZBaimo/Nginx-quic/actions/workflows/build.yml)
[![GHCR Image](https://img.shields.io/badge/ghcr.io-nginx--quic-blue.svg)](https://github.com/ZBaimo/Nginx-quic/pkgs/container/nginx-quic)
[![Docker Hub](https://img.shields.io/badge/docker.io-nginx--quic-blue.svg)](https://hub.docker.com/r/zbaimo/nginx-quic)

支持 HTTP/3 (QUIC) 协议的 Nginx Docker 镜像，基于 OpenSSL 4.0.0 编译。

## ✨ 特性

- HTTP/3 (QUIC) + HTTP/2 完整支持
- 多架构：linux/amd64, linux/arm64
- 自动构建发布到 Docker Hub 和 GHCR
- 基于 Alpine Linux，镜像轻量

## 🚀 快速开始

### 使用预构建镜像

```bash
# Docker Hub
docker pull zbaimo/nginx-quic:latest
docker run -d -p 80:80 -p 443:443 -p 443:443/udp zbaimo/nginx-quic:latest

# GHCR
docker pull ghcr.io/zbaimo/nginx-quic:latest
docker run -d -p 80:80 -p 443:443 -p 443:443/udp ghcr.io/zbaimo/nginx-quic:latest
```

### 本地构建运行

```bash
# 1. 克隆项目
git clone https://github.com/ZBaimo/Nginx-quic.git && cd Nginx-quic

# 2. 生成测试证书（生产环境请使用正式证书）
chmod +x generate-ssl.sh && ./generate-ssl.sh

# 3. 启动服务
docker-compose up -d
```

## 📖 详细教程

### 更新版本并重新编译

当 Nginx 或 OpenSSL 发布新版本时，按照以下步骤更新：

#### 1. 查看最新版本

- **Nginx**: https://nginx.org/en/download.html
- **OpenSSL**: https://www.openssl.org/source/

#### 2. 修改版本号（三处需同步更新）

**① Dockerfile**（第 5-6 行）
```dockerfile
ARG NGINX_VERSION=1.30.0
ARG OPENSSL_VERSION=4.0.0
```

**② docker-compose.yml**（build.args 部分）
```yaml
build:
  args:
    NGINX_VERSION: 1.30.0
    OPENSSL_VERSION: 4.0.0
```

**③ .github/workflows/build.yml**（第 83-84 行）
```yaml
build-args: |
  NGINX_VERSION=1.30.0
  OPENSSL_VERSION=4.0.0
```

> 💡 **提示**：这三处必须保持一致，否则会导致构建版本不匹配。

### 验证 HTTP/3

```bash
# 使用 curl（需支持 HTTP/3 的版本）
curl -I --http3 https://localhost

# 浏览器访问 https://localhost，F12 查看 Network 标签的 Protocol 列
# 应显示 h3 或 http/3
```

## ⚙️ 配置说明

### 端口

| 端口 | 协议 | 说明 |
|------|------|------|
| 80 | HTTP | 自动重定向到 HTTPS |
| 443/tcp | HTTPS | HTTP/1.1, HTTP/2 |
| 443/udp | QUIC | HTTP/3 |

### 核心配置

- **QUIC 优化**: `quic_retry on` + `quic_gso on`
- **TLS 1.3 0-RTT**: `ssl_early_data on`
- **Gzip 压缩**: 自动压缩文本内容
- **工作进程**: 自动根据 CPU 核心数调整

### 自定义配置

挂载自己的配置文件：

```bash
docker run -d \
  -v $(pwd)/custom-nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/custom-site.conf:/etc/nginx/conf.d/default.conf:ro \
  zbaimo/nginx-quic:latest
```

## 🔄 CI/CD 自动构建

触发条件：
- 推送 `Dockerfile`、`nginx.conf`、`default.conf` 或 `build.yml` 时自动构建
- 每周一 00:00 UTC 定时构建
- 支持手动触发

**防重复机制**：同一分支的并发构建会自动取消，只保留最新一次执行。

## 📝 版本历史

| 日期 | Nginx | OpenSSL | Docker 镜像标签 | 说明 |
|------|-------|---------|----------------|------|
| 2026-05-17 | 1.30.0 | 4.0.0 | `v26.5.17` | 目前最新版本，可以用latest的tag更新 |

## 📚 参考

- [Nginx QUIC 文档](https://nginx.org/en/docs/quic.html)
- [HTTP/3 explained](https://http3-explained.haxx.se/)

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

⭐ 如果这个项目对你有帮助，请给个 Star！
