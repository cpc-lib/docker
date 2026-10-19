# Docker Compose 实战手册

一个 Docker 学习与实战参考仓库，涵盖 **Docker 完整教程**、**前后端 Dockerfile 模板**、**40+ docker-compose 一键部署案例**、**Ubuntu 在线安装**、**Docker / Compose 离线部署** 以及 **Linux 生产网络与启动优化**。

---

## 目录结构

```
docker-compose/
├── Docker/              # Docker 学习手册（16 章完整教程）
├── Dockerfile/          # Dockerfile 构建模板
│   ├── frontend/        #   前端（Vue/React + nginx）
│   └── backend/         #   后端（Spring Boot jar）
└── Linux/               # docker-compose 实战案例（40+ 服务）
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
| `jenkins/` | Jenkins | CI/CD 运维管理脚本 |
| `qbittorrent/` | qBittorrent | BT 下载客户端 |

### 其他

| 目录 | 说明 |
| --- | --- |
| `idempotency/` | 幂等性演示（MySQL + Nginx） |
| `gray/` | 灰度发布平台（MySQL + Prometheus） |
| `sha256/` | SHA256 演示 |
| `sharding/` | 分库分表 |

---

## 四、快速开始

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

## 五、Ubuntu 在线安装 Docker

在 Ubuntu 系统（支持 18.04 / 20.04 / 22.04 / 24.04 LTS 等版本）上，推荐使用官方 APT 存储库或官方便捷脚本进行在线安装。

> 参考资料：[菜鸟教程 - Ubuntu Docker 安装](https://www.runoob.com/docker/ubuntu-docker-install.html)

### 1. 卸载旧版本（可选）

如果系统中已安装过旧版本 Docker（如 `docker`、`docker.io` 或 `docker-engine`），建议先清理：

```bash
sudo apt-get remove -y docker docker-engine docker.io containerd runc
```

### 2. 方式一：使用 APT 存储库安装（生产推荐）

#### (1) 更新 apt 索引并安装基础依赖
```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https software-properties-common
```

#### (2) 添加 Docker 官方 GPG 密钥
```bash
# 创建密钥存放目录
sudo install -m 0755 -d /etc/apt/keyrings

# 方式 A（官方源）：
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 方式 B（国内服务器推荐 - 阿里云源）：
# curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 赋予密钥读取权限
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

#### (3) 设置稳定的软件源仓库
```bash
# 写入官方 APT 源
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 若国内网络拉取慢，可替换为阿里云源：
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
#   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

#### (4) 安装 Docker Engine 与 Docker Compose 插件
```bash
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

> **提示**：如需安装特定版本，可使用 `apt-cache madison docker-ce` 查询可用版本列表，并执行 `sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io` 进行安装。

---

### 3. 方式二：使用官方便捷脚本一键安装（开发/测试推荐）

Docker 官方提供了自动化安装脚本，能够自动检测 Linux 发行版并配置软件源：

```bash
# 下载官方脚本并运行
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 国内服务器可添加参数指定阿里云镜像源加速：
# curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
```

---

### 4. 启动服务与非 root 用户配置

#### (1) 启动 Docker 并设置开机自启
```bash
sudo systemctl enable --now docker
sudo systemctl status docker
```

#### (2) 免 sudo 配置（可选）
默认仅 root 或拥有 sudo 权限的用户才能运行 Docker 命令。若需要让普通用户直接运行 Docker，可将当前用户加入 `docker` 组：

```bash
# 创建 docker 用户组（通常安装时已自动创建）
sudo groupadd docker

# 将当前用户加入 docker 组
sudo usermod -aG docker $USER

# 刷新用户组（或注销后重新登录终端生效）
newgrp docker
```

---

### 5. 配置国内镜像加速器（可选）

为提高镜像拉取速度，可配置国内镜像源：

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://docker.m.daocloud.io"
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me",
    "https://docker.m.daocloud.io",
    "https://hub.rat.dev"
  ]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

### 6. 验证安装

```bash
docker --version
docker compose version
sudo docker run --rm hello-world
```

---

## 六、Docker 与 Docker Compose 离线安装指南

在金融、政企或隔离内网（无公网访问权限）的生产环境中，无法使用 `yum` / `apt` 或在线脚本自动下载。本指南提供基于官方静态二进制包在 Linux（CentOS / Ubuntu / RHEL 等）环境下进行**全离线安装与托管**的完整方案。

> 推荐参考：[稀土掘金 - Linux 生产环境 Docker/Compose 离线安装](https://juejin.cn/post/7624444910117961768)

### 1. 离线安装包准备（在有外网机器上操作）

#### (1) 下载 Docker 静态二进制包
访问 Docker 官方静态包发布仓库：
- **下载地址**：[https://download.docker.com/linux/static/stable/x86_64/](https://download.docker.com/linux/static/stable/x86_64/)
- 选择所需稳定版本（如 `docker-24.0.7.tgz` 或更新版）并下载：
  ```bash
  # 示例（x86_64 架构）
  wget https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz
  ```

#### (2) 获取 Docker Compose 二进制包
访问 [GitHub Releases: docker/compose](https://github.com/docker/compose/releases) 下载对应系统架构的二进制文件（如 `docker-compose-linux-x86_64`），并重命名为 `docker-compose`。

---

### 2. Docker 离线安装步骤

将下载的 `docker-*.tgz` 上传至目标离线服务器（如 `/root` 目录）：

#### (1) 解压并移动二进制文件到系统 PATH
```bash
# 解压
tar -zxvf docker-24.0.7.tgz

# 将解压出来的二进制文件移动到系统可执行目录 /usr/bin
sudo cp docker/* /usr/bin/

# 验证二进制可正常调用
dockerd --version
docker --version
```
> 解压包含的核心组件：`docker`（命令行客户端）、`dockerd`（守护进程）、`containerd`、`runc`、`containerd-shim`、`docker-init`、`docker-proxy` 等。

#### (2) 创建 Systemd 服务文件托管 Docker
创建系统服务配置文件 `/etc/systemd/system/docker.service`，实现服务的标准化生命周期管理与开机自启：

```bash
sudo tee /etc/systemd/system/docker.service <<-'EOF'
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
```

> **注意**：此处配置已默认整合 `After=network-online.target` 与 `Wants=network-online.target`，保证开机时网络服务完全就绪后再拉起 Docker，避免网络竞态引发的网桥冲突与端口映射异常。如果系统为 Ubuntu 且未使用 firewalld，可省去 `firewalld.service`。

#### (3) 赋予权限并启动 Docker
```bash
# 赋予 service 文件可执行权限
sudo chmod +x /etc/systemd/system/docker.service

# 重新加载 systemd 配置
sudo systemctl daemon-reload

# 设置开机自启并立即启动 Docker 服务
sudo systemctl enable --now docker

# 查看服务运行状态
sudo systemctl status docker
```

#### (4) 验证 Docker 功能
```bash
docker info
```

---

### 3. Docker Compose 离线安装步骤

#### (1) 部署二进制文件与权限配置
将 `docker-compose` 二进制文件上传至目标服务器：

```bash
# 复制至可执行目录
sudo cp docker-compose /usr/local/bin/docker-compose

# 赋予可执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 建立软链接至 /usr/bin，保证各环境变量和脚本均可识别
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
```

#### (2) 验证安装
```bash
docker-compose --version
# 输出示例：docker-compose version 1.29.2 或 Docker Compose version v2.x.x
```

---

### 4. 离线环境运维技巧：镜像导入与导出

在无法连接公网镜像源的纯内网机上，可通过离线镜像归档完成镜像分发：

```bash
# 1. 在有网机器上导出镜像为 tar 文件
docker save -o mysql-5.7.tar mysql:5.7

# 批量导出多个镜像
docker save -o web-stack.tar nginx:1.21.1 redis:6.2 mysql:5.7

# 2. 拷贝至内网离线机后，导入镜像
docker load -i mysql-5.7.tar
docker load -i web-stack.tar

# 3. 验证本地镜像列表
docker images
```

---

## 七、Docker 启动顺序与生产网络优化（CentOS / Ubuntu）

在 Linux 生产环境中，Docker 服务若在系统网络完全就绪之前启动，常导致容器网络初始化异常、网桥冲突或端口映射失效。以下提供基于 systemd 的启动顺序优化与故障排查方案。

### 1. 问题背景

在 CentOS、Ubuntu 等 Linux 服务器上，Docker 可能在系统网络尚未完全就绪时启动，导致容器网络初始化或端口映射出现异常。

通过 systemd 配置，可以让 Docker **在网络达到 `network-online.target` 之后启动**，降低开机阶段出现网络竞态的概率。

> **适用范围**：本方案主要优化**服务器开机时**的 Docker 启动顺序；并不能保证网络服务在运行期间重启后，Docker 会自动恢复失效的端口映射。

### 2. 配置 Docker 启动顺序

#### (1) 创建 systemd 覆盖配置

CentOS / Ubuntu 通用：

```bash
sudo systemctl edit docker.service
```

在打开的编辑器中加入：

```ini
[Unit]
Wants=network-online.target
After=network-online.target
After=firewalld.service
```

**配置说明**：

| 配置项 | 作用 |
| --- | --- |
| `Wants=network-online.target` | Docker 启动时，尝试拉起网络就绪目标。 |
| `After=network-online.target` | 规定 Docker 必须排在网络就绪目标之后启动。 |
| `After=firewalld.service` | 如果 `firewalld.service` 也在启动事务中，则让 Docker 排在它后面启动。 |

**注意事项**：
- `After=` 只定义启动先后顺序，不会主动启动所指定的服务。因此，`After=firewalld.service` **不等于**启用或启动 firewalld。
- Ubuntu 常见防火墙管理工具为 UFW，通常没有运行 `firewalld.service`；这一行在没有该服务时可以省略。
- `network-online.target` 是否确实等待网络就绪，取决于对应的等待服务是否正确配置，如 `NetworkManager-wait-online.service` 或 `systemd-networkd-wait-online.service`。
- 建议使用 `systemctl edit` 添加 drop-in 配置，不要直接修改系统自带的 `/usr/lib/systemd/system/docker.service` 或 `/lib/systemd/system/docker.service`。

#### (2) 重新加载 systemd 配置

```bash
sudo systemctl daemon-reload
```

新配置将在 Docker **下一次启动**时生效。可以在合适的维护窗口重启 Docker 以验证配置：

```bash
sudo systemctl restart docker
```

> **注意**：重启 Docker 可能中断正在运行的容器或其网络连接，生产环境应安排维护窗口。

### 3. 验证配置是否生效

#### (1) 查看完整 unit 配置

```bash
systemctl cat docker.service
```

检查输出中是否包含新增的 drop-in 内容。

#### (2) 查看依赖及启动顺序

```bash
systemctl show docker.service -p After -p Wants
```

确认 `After` 中包含 `network-online.target`，`Wants` 中包含 `network-online.target`。

#### (3) 检查网络等待服务（按实际网络管理方式）

如果系统使用 NetworkManager：

```bash
systemctl status NetworkManager-wait-online.service
```

如果系统使用 systemd-networkd：

```bash
systemctl status systemd-networkd-wait-online.service
```

*注：应根据系统实际采用的网络管理器配置等待服务，不要同时盲目启用多个网络管理器。*

### 4. 解决边界与场景分析（能解决什么 / 不能解决什么？）

| 场景 | 本配置的效果 |
| --- | --- |
| 服务器开机时 Docker 早于网络就绪启动 | **可降低**启动竞态导致的异常概率。 |
| Docker 初始化网桥时依赖的网络条件未满足 | 可以改善部分因开机时序造成的问题。 |
| 运行期间执行 `systemctl restart NetworkManager` | **不能保证**自动恢复 Docker 网络。 |
| 运行期间重启 firewalld / UFW 后端口映射不可访问 | **不能保证**自动修复丢失或变更的防火墙/NAT 规则。 |
| Docker 网桥被 NetworkManager 或其他网络服务接管 | **不能解决**，需要调整网络管理规则。 |

### 5. 运行期间网络重启造成端口映射失效的排查方向

如果 Docker 已正常启动，但重启网络服务后容器端口无法访问，建议按以下方向定位根因：

1. **检查 Docker 服务与容器状态**：使用 `systemctl status docker`、`docker ps` 确认服务与容器是否仍正常运行。
2. **检查端口发布配置**：使用 `docker ps` 和 `docker port <容器名或ID>`，确认端口仍然按预期发布。
3. **检查防火墙及 NAT 规则**：核查 firewalld、UFW、iptables 或 nftables，确认网络重启时是否刷新、覆盖了 Docker 创建的规则。
4. **检查 Docker 网桥管理归属**：确认 `docker0`、`br-*` 等接口没有被 NetworkManager 或其他网络管理器错误接管。
5. **检查 Docker daemon 配置**：确认 `/etc/docker/daemon.json` 中没有意外关闭 Docker 的防火墙规则管理（如 `"iptables": false`）；注意不同 Docker 网络后端及版本的配置差异。
6. **检查服务日志**：通过 `journalctl -u docker -b` 和对应网络、防火墙服务日志定位规则被清理或接口被重建的时间点。

> **建议**：优先修复造成 Docker 网桥或防火墙规则异常的服务配置，避免将每次网络重启后执行 `systemctl restart docker` 作为长期解决方案。

### 6. 核心总结

通过下面的 systemd drop-in 配置，可以优化 Docker 的**开机启动顺序**：

```ini
[Unit]
Wants=network-online.target
After=network-online.target
After=firewalld.service
```

其中 `After=firewalld.service` 应根据服务器实际是否使用 firewalld 决定是否保留。

**核心结论：**
- **开机启动问题**：通过 `network-online.target` 优化依赖与顺序。
- **运行期间网络重启问题**：应检查防火墙/NAT 规则及 Docker 网桥的管理冲突，针对根因修复。
- **避免混淆**：“网络就绪后启动 Docker”与“网络重启后自动恢复 Docker 端口映射”是两类不同的问题。

---

## 八、环境要求

- Docker >= 20.10
- Docker Compose >= 1.29
- 部分案例需要 Linux 服务器（MySQL 绝对路径挂载等）

---

## License

[MIT License](LICENSE)
