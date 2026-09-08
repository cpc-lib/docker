# Docker Compose 实战手册

一个 Docker 学习与实战参考仓库，涵盖 **Docker 完整教程**、**前后端 Dockerfile 模板**、**40+ docker-compose 一键部署案例**。

---

## 目录结构

```
docker-compose/
├── Docker/              # Docker 学习手册（16 章完整教程）
├── Dockerfile/          # Dockerfile 构建模板
│   ├── frontend/        #   前端（Vue/React + nginx）
│   └── backend/         #   后端（Spring Boot jar）
├── Linux/               # docker-compose 实战案例（40+ 服务）
└── docker-compose       # Docker Compose 二进制可执行文件（Linux amd64）
```

---

## 一、Docker 学习手册

[Docker/README.md](Docker/README.md) — 从入门到进阶，16 章完整教程：

| 章节 | 内容 |
| --- | --- |
| 1-4 | 简介、安装、快速开始、常用命令 |
| 5-7 | 镜像管理、私有仓库、Dockerfile 构建 |
| 8-10 | Compose、容器网络、容器运维 |
| 11-12 | 安全与远程访问、可视化管理（Portainer） |
| 13-14 | Docker Swarm 集群、Watchtower 自动更新 |
| 15-16 | 问题排查、Docker Desktop |

---

## 二、Dockerfile 构建模板

| 目录 | 基础镜像 | 用途 | 说明 |
| --- | --- | --- | --- |
| [frontend/](Dockerfile/frontend/) | nginx:1.21.1 | Vue / React 前端 | SPA 路由 + 完整 nginx 配置（反代/WS/TCP代理） |
| [backend/](Dockerfile/backend/) | openjdk:8-jre-alpine | Spring Boot jar | 运行时 `-e JAVA_OPTS` 动态传参 |

**frontend/nginx.conf 涵盖**：
- 前端静态资源 + SPA 路由刷新 404 兜底
- HTTP 反向代理 + 真实 IP 透传 + 限流 + 缓存
- WebSocket / SSE 长连接代理
- HTTPS + HSTS（模板注释）
- TCP/UDP 4 层代理（MySQL / Redis / RabbitMQ / DNS）
- gzip / 安全头 / 负载均衡 / 健康检查

---

## 三、docker-compose 实战案例

[Linux/](Linux/) 下 40+ 个服务的一键部署编排：

### 数据库

| 目录 | 服务 | 说明 |
| --- | --- | --- |
| `mysql/` | MySQL 5.7 | 单机 + Canal |
| `mysql57/` | MySQL 5.7 | 单机版 |
| `mysql57-monitor/` | MySQL 5.7 + 监控 | Prometheus + Grafana + exporter |
| `mysql8/` | MySQL 8.0 | 单机版 |
| `mysql-cluster/` | MySQL 集群 | 一主两从 |
| `postgresql/` | PostgreSQL | 单机版 |
| `mongodb/` | MongoDB | 单机版 |
| `mongo-cluster/` | MongoDB 集群 | 副本集 |
| `redis/` | Redis | 单机版 |
| `sentinel/` | Redis Sentinel | 哨兵模式 |
| `kafka/` | Kafka | 单机版 |
| `dm8/` | 达梦 DM8 | 国产数据库 |

### 消息队列

| 目录 | 服务 | 说明 |
| --- | --- | --- |
| `rabbitmq/` | RabbitMQ | 单机版 |
| `rabbitmq-mqtt/` | RabbitMQ MQTT | MQTT 插件 |
| `rabbitmq-haproxy/` | RabbitMQ 集群 + HAProxy | 双节点 + 负载均衡 |
| `rocketmq/` | RocketMQ | 4.x 单机 |
| `rocketmq5/` | RocketMQ | 5.x 单机 |

### 搜索引擎 & 日志

| 目录 | 服务 | 说明 |
| --- | --- | --- |
| `elk/` | ELK | Elasticsearch + Logstash + Kibana |
| `elk-cluster/` | ELK 集群 | Logstash pipeline |
| `canal/` | Canal + MySQL | MySQL binlog 订阅 |
| `zipkin-elk/` | Zipkin + ELK | 链路追踪 |

### 对象存储

| 目录 | 服务 | 说明 |
| --- | --- | --- |
| `minio/` | MinIO | 单机版 |
| `minio-cluster/` | MinIO 集群 | 4 节点分布式 |

### AI / RAG

| 目录 | 服务 | 说明 |
| --- | --- | --- |
| `rag-base/` | RAG 基础版 | 向量检索 |
| `rag-pro/` | RAG 专业版 | ES + Redis + RabbitMQ + WireMock |
| `milvus/` | Milvus + Redis | 向量数据库 |
| `ai-demo/` | AI Demo | Milvus + MinIO + etcd |
| `ai-vocab-card/` | AI 单词卡 | Milvus adapter |

### DevOps & 工具

| 目录 | 服务 | 说明 |
| --- | --- | --- |
| `gogs/` | Gogs | Git 服务 |
| `artemis/` | Artemis | 任务调度 |
| `job/elasticjob/` | ElasticJob | 分布式任务 |
| `job/powerjob/` | PowerJob | 分布式任务 |
| `influxdb/` | InfluxDB | 时序数据库 |

### 其他

| 目录 | 说明 |
| --- | --- |
| `idempotency/` | 幂等性演示（MySQL + Nginx） |
| `gray/` | 灰度发布平台（MySQL + Prometheus） |
| `sha256/` | SHA256 演示 |
| `sharding/` | 分库分表 |

---

## 快速开始

```shell
# 1. 进入任意服务目录
cd Linux/mysql

# 2. 一键启动
docker-compose up -d

# 3. 查看状态
docker-compose ps

# 4. 停止并删除
docker-compose down
```

构建前后端镜像：

```shell
# 前端
cd Dockerfile/frontend
npm run build          # 本地打包产出 dist/
docker build -t frontend-app:dev .
docker run -d -p 80:80 frontend-app:dev

# 后端
cd Dockerfile/backend
# 把 jar 包放到同级目录
docker build -t backend-app:dev .
docker run -d -p 8080:8080 -e JAVA_OPTS="-Xms256m -Xmx512m" backend-app:dev
```

---

## 环境要求

- Docker >= 20.10
- Docker Compose >= 1.29
- 部分案例需要 Linux 服务器（MySQL 绝对路径挂载等）

---

## License

[MIT License](LICENSE)
