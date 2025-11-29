# Multi-stage build for Nginx with QUIC support
FROM alpine:3.19 AS builder

# Define versions
ARG NGINX_VERSION=1.28.0
ARG OPENSSL_VERSION=3.6.0

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    linux-headers \
    pcre-dev \
    zlib-dev \
    wget \
    git \
    cmake \
    go \
    perl

# Set working directory
WORKDIR /src

# Download and extract OpenSSL with QUIC support
RUN wget https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz && \
    tar -xzf openssl-${OPENSSL_VERSION}.tar.gz

# Download and extract Nginx
RUN wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -xzf nginx-${NGINX_VERSION}.tar.gz

# Configure and build Nginx with QUIC support
WORKDIR /src/nginx-${NGINX_VERSION}
RUN ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-cc-opt="-O3 -fPIE -fstack-protector-strong" \
    --with-ld-opt="-Wl,-z,relro,-z,now" \
    --with-openssl=/src/openssl-${OPENSSL_VERSION} \
    --with-openssl-opt='enable-ktls' && \
    make -j$(nproc) && \
    make install

# Runtime stage
FROM alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache \
    pcre \
    zlib \
    ca-certificates \
    tzdata

# Create nginx user and group
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Copy nginx binary and configuration from builder
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx

# Create necessary directories
RUN mkdir -p /var/cache/nginx/client_temp \
    /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp \
    /var/cache/nginx/uwsgi_temp \
    /var/cache/nginx/scgi_temp \
    /var/log/nginx \
    /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Create a simple index page
RUN echo '<html><head><title>Nginx with QUIC</title></head><body><h1>Nginx with HTTP/3 (QUIC) Support</h1><p>Server is running successfully!</p></body></html>' > /usr/share/nginx/html/index.html

# Expose ports
EXPOSE 80 443 443/udp

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Stop signal
STOPSIGNAL SIGQUIT

# Run nginx
CMD ["nginx", "-g", "daemon off;"]

