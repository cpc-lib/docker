# 前端 Dockerfile 使用说明

本目录提供前端应用（Vue/React）的 Docker 镜像构建方案，基于 nginx 镜像，将本地打包后的静态资源部署到容器，并附带完整的 nginx 配置模板（含 HTTP 反代、WebSocket、TCP 代理等）。

---

## 一、文件结构

```
frontend/
├── Dockerfile       # 构建镜像的 Dockerfile
├── nginx.conf       # nginx 完整配置模板（含详细注释）
└── README.md        # 本文档
```

构建时还需在同级目录放入本地打包产物 `dist/`：

```
frontend/
├── Dockerfile
├── nginx.conf
├── README.md
└── dist/            # 本地打包产物
```

---

## 二、打包产物要求

本地需先执行打包命令产出 `dist/` 目录：

| 脚手架 | 打包命令 | 产物目录 | 是否需改 Dockerfile |
| --- | --- | --- | --- |
| Vue (vite) | `npm run build` | `dist/` | 否 |
| React (vite) | `npm run build` | `dist/` | 否 |
| React (CRA) | `npm run build` | `build/` | 是，将 `COPY dist/` 改为 `COPY build/` |

---

## 三、构建镜像

```shell
# -f：指定Dockerfile文件路径
# -t：镜像命名
# --no-cache：构建镜像时不使用缓存
# 最后的 "."：构建上下文路径，将此路径下所有文件打包上传给Docker引擎
docker build -f Dockerfile -t frontend-app:dev . --no-cache
```

---

## 四、运行容器

### 1. 基本运行

```shell
docker run -d -p 80:80 \
--name frontend-app \
--restart=always \
frontend-app:dev
```

访问 http://127.0.0.1

### 2. 参数说明

| 参数 | 作用 |
| --- | --- |
| `-d` | 后台运行 |
| `-p 80:80` | 端口映射：宿主机端口:容器端口 |
| `--name frontend-app` | 容器名 |
| `--restart=always` | 容器退出时总是重启 |

### 3. 进入容器

```shell
docker exec -it frontend-app /bin/bash
cd /usr/share/nginx/html   # 查看静态资源
```

---

## 五、nginx.conf 配置说明

本 Dockerfile 用 `COPY nginx.conf /etc/nginx/conf.d/default.conf` 将本地 nginx 配置替换进镜像。`nginx.conf` 是一份**完整配置模板**，涵盖前端静态资源、HTTP 反代、WebSocket、TCP/UDP 代理等功能，按需启用或注释。

### 1. 模块结构

| 模块 | 层级 | 用途 |
| --- | --- | --- |
| `events` | 顶级 | 事件模型、并发连接数 |
| `http` | 顶级 | HTTP/HTTPS 服务、反向代理、WebSocket、负载均衡 |
| `stream` | 顶级（与 http 并列） | TCP/UDP 4 层代理 |

> ⚠️ `stream` 与 `http` 是**顶级并列**关系，不能嵌套。

### 2. http 模块功能清单

| 功能 | location / 指令 | 说明 |
| --- | --- | --- |
| 前端静态资源 | `location /` | `try_files $uri $uri/ /index.html` 解决 SPA 路由刷新 404 |
| HTTP 反向代理 | `location /api/` | 转发到 `upstream backend_api`，含限流 + 真实 IP 透传 + 响应缓存 |
| WebSocket | `location /ws` | `Upgrade`/`Connection: upgrade` + 3600s 长连接 + 关闭缓冲 |
| SSE 长连接 | `location /sse` | 关闭缓冲 + chunked + 3600s，支持 Server-Sent Events |
| 健康检查 | `location = /health` | 返回 200 "ok"，供 docker/k8s 探针使用 |
| 静态资源缓存 | `location ~* \.(js\|css\|png...)$` | js/css/图片长缓存 30d，html 不缓存 |
| 安全头 | `add_header` | X-Frame-Options / X-Content-Type-Options / X-XSS-Protection / Referrer-Policy |
| 限流 | `limit_req` / `limit_conn` | 每 IP 每秒 10 请求 + 并发 50 |
| gzip | `gzip on` | 级别 6 + 类型白名单，减小传输体积 |
| 负载均衡 | `upstream backend_api` | 4 种调度策略：轮询/least_conn/ip_hash/hash $request_uri |
| HTTPS | 注释模板 | TLS1.2/1.3 + HSTS + HTTP→HTTPS 跳转 |

### 3. stream 模块功能清单

| 服务 | 代理端口 → 目标 | 协议 |
| --- | --- | --- |
| MySQL | 13306 → 192.168.101.90:3306 | TCP |
| Redis | 16379 → 192.168.101.90:6379 | TCP |
| RabbitMQ | 15672 → 192.168.101.90:5672 | TCP |
| DNS | 15353 → 8.8.8.8:53 | UDP（注释示例） |
| syslog | 1514 → 192.168.101.90:514 | UDP（注释示例） |

### 4. 关键配置说明

#### WebSocket 反代（必读）

```nginx
location /ws {
    proxy_pass http://backend_api/ws;
    proxy_http_version 1.1;                      # 必需：HTTP/1.1 才支持升级
    proxy_set_header Upgrade    $http_upgrade;    # 必需：升级协议头
    proxy_set_header Connection "upgrade";       # 必需：连接类型
    proxy_read_timeout  3600s;                   # 必需：默认 60s 会断开 WS
    proxy_buffering off;                         # 关闭缓冲，避免数据延迟
}
```

#### stream vs http

| 模块 | OSI 层 | 处理对象 | 关键指令 |
| --- | --- | --- | --- |
| `http` | 7 层 | HTTP/WS 请求 | `location` + `proxy_pass http://upstream` |
| `stream` | 4 层 | TCP/UDP 流 | `server` + `proxy_pass upstream`（不带 http://） |

#### 负载均衡调度策略

| 策略 | 指令 | 适用场景 |
| --- | --- | --- |
| 轮询（默认） | 无 | 后端性能相近 |
| 最少连接 | `least_conn;` | 后端性能不均 |
| IP 哈希 | `ip_hash;` | 需会话粘性 |
| URI 哈希 | `hash $request_uri;` | 提高缓存命中 |

---

## 六、与后端联合部署

### 1. docker-compose 编排

```yml
version: '3'
services:
  frontend:
    image: frontend-app:dev
    container_name: frontend-app
    restart: always
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - app-net

  backend:
    image: backend-app:dev
    container_name: backend-app
    restart: always
    ports:
      - "8080:8080"
    environment:
      JAVA_OPTS: "-Xms256m -Xmx512m"
    networks:
      - app-net

networks:
  app-net:
    driver: bridge
```

### 2. 修改 nginx.conf 中的上游地址

同 docker-compose 网络下，用**容器名**通信（无需写 IP）：

```nginx
upstream backend_api {
    server backend:8080;     # backend 是 compose 中定义的容器名/服务名
}
```

### 3. 请求链路

```
浏览器 → frontend(nginx:80)
         ├── /            → 静态资源 /usr/share/nginx/html
         ├── /api/xxx     → proxy_pass → backend:8080/xxx
         └── /ws          → WebSocket  → backend:8080/ws
```

---

## 七、常见问题

### 1. 路由刷新 404

SPA 应用（Vue Router / React Router）刷新子路由报 404，原因是 nginx 找不到对应文件。需确保 `location /` 中有：

```nginx
try_files $uri $uri/ /index.html;
```

### 2. WebSocket 连接自动断开

nginx 反代 WebSocket 默认 60s 超时断开，需调大 `proxy_read_timeout` 和 `proxy_send_timeout`（本模板已设为 3600s）。

### 3. 修改 nginx.conf 后不生效

- 修改 `nginx.conf` 后**需重新构建镜像**（因为是 `COPY` 进去的）
- 或运行时挂载覆盖：`-v /宿主机路径/nginx.conf:/etc/nginx/conf.d/default.conf`

```shell
# 运行时挂载方式（改配置无需重新构建镜像）
docker run -d -p 80:80 \
-v /home/zhengqingya/nginx/nginx.conf:/etc/nginx/conf.d/default.conf \
--name frontend-app \
frontend-app:dev
```

### 4. HTTPS 启用

取消 `nginx.conf` 中 HTTPS server 块的注释，挂载证书：

```shell
docker run -d -p 80:80 -p 443:443 \
-v /宿主机证书路径/server.crt:/etc/nginx/ssl/server.crt:ro \
-v /宿主机证书路径/server.key:/etc/nginx/ssl/server.key:ro \
--name frontend-app \
frontend-app:dev
```

### 5. stream 模块不可用

nginx 官方镜像默认编译了 stream 模块，一般无需额外安装。如遇报错 `unknown directive "stream"`，确认镜像是否为官方完整版（非 nginx:alpine 的精简变体）。
