# 后端 jar 包 Dockerfile 使用说明

本 Dockerfile 用于构建 Spring Boot 等 Java jar 应用的 Docker 镜像，通过 `ENV JAVA_OPTS` 声明环境变量，**运行时以 `-e` 动态传入 JVM 参数**，同一镜像可用不同参数启动，无需重新构建。

---

## 一、文件准备

把 jar 包放到 Dockerfile 同级目录：

```
backend/
├── Dockerfile
└── app.jar
```

---

## 二、构建镜像

```shell
# -f：指定Dockerfile文件路径
# -t：镜像命名
# --no-cache：构建镜像时不使用缓存
# 最后的 "."：构建上下文路径，将此路径下所有文件打包上传给Docker引擎
docker build -f Dockerfile -t backend-app:dev . --no-cache
```

---

## 三、运行容器（传递 JAVA_OPTS 参数）

### 1. 基本运行

```shell
docker run -d -p 8080:8080 \
-e JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC" \
--name backend-app \
--restart=always \
backend-app:dev
```

### 2. 参数说明

| 参数 | 作用 |
| --- | --- |
| `-d` | 后台运行 |
| `-p 8080:8080` | 端口映射：宿主机端口:容器端口 |
| `-e JAVA_OPTS="..."` | **运行时传入 JVM 参数，覆盖 ENV 默认值** |
| `--name backend-app` | 容器名 |
| `--restart=always` | 容器退出时总是重启 |

### 3. 验证参数是否生效

查看容器日志，会打印实际执行的命令：

```shell
docker logs -f backend-app
# ****** 运行命令：java -jar -Xms256m -Xmx512m -XX:+UseG1GC /home/app.jar
```

---

## 四、JAVA_OPTS 常用示例

```shell
# 1、堆内存 + G1 垃圾回收器
-e JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC"

# 2、指定 Spring Profile
-e JAVA_OPTS="-Dspring.profiles.active=prod -Xmx512m"

# 3、远程调试（需额外暴露 5005 端口）
docker run -d -p 8080:8080 -p 5005:5005 \
-e JAVA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005" \
--name backend-app \
backend-app:dev

# 4、时区 + 编码 + 堆内存
-e JAVA_OPTS="-Duser.timezone=Asia/Shanghai -Dfile.encoding=UTF-8 -Xms256m -Xmx512m"

# 5、不传 JAVA_OPTS（使用默认空值）
docker run -d -p 8080:8080 --name backend-app backend-app:dev
# ****** 运行命令：java -jar  /home/app.jar
```

---

## 五、docker-compose 方式

```yml
version: '3'
services:
  backend:
    image: backend-app:dev
    container_name: backend-app
    restart: always
    ports:
      - "8080:8080"
    environment:
      JAVA_OPTS: "-Xms256m -Xmx512m -XX:+UseG1GC"
```

```shell
docker-compose up -d
```

---

## 六、日志挂载到数据卷

容器内日志默认写在容器内部，容器删除后日志随之丢失。通过 `-v` 将宿主机目录挂载到容器内日志路径，即可在宿主机直接查看和持久化日志。

### 1. 两种日志的区别

| 日志类型 | 路径 | 说明 |
| --- | --- | --- |
| 容器 stdout/stderr | docker 日志驱动管理 | `docker logs` 查看，默认存于 `/var/lib/docker/containers/<id>/` |
| 应用业务日志 | jar 内部输出路径（如 `/home/logs/`） | Spring Boot 的 logback/log4j 配置的输出目录 |

> 下面挂载的是**应用业务日志**，让 jar 写出的日志文件持久化到宿主机。

### 2. docker run 方式

```shell
# 假设 jar 中日志配置输出到 /home/logs/ 目录
docker run -d -p 8080:8080 \
-e JAVA_OPTS="-Xms256m -Xmx512m" \
-v /home/logs/backend-app:/home/logs \
--name backend-app \
--restart=always \
backend-app:dev
```

| 参数 | 作用 |
| --- | --- |
| `-v 宿主机路径:容器路径` | 将宿主机目录挂载到容器内日志目录 |
| `/home/logs/backend-app` | 宿主机日志存放路径（需先创建） |
| `/home/logs` | 容器内 jar 的日志输出路径（与 Spring Boot 日志配置一致） |

查看宿主机日志：

```shell
# 宿主机直接查看日志文件
ls -lh /home/logs/backend-app
tail -f /home/logs/backend-app/app.log

# 或通过 docker logs 查看容器 stdout 日志
docker logs -f backend-app
```

### 3. docker-compose 方式

```yml
version: '3'
services:
  backend:
    image: backend-app:dev
    container_name: backend-app
    restart: always
    ports:
      - "8080:8080"
    environment:
      JAVA_OPTS: "-Xms256m -Xmx512m -XX:+UseG1GC"
    volumes:
      # 挂载日志目录：宿主机路径:容器内日志路径
      - "/home/logs/backend-app:/home/logs"
      # 挂载数据目录（可选）
      - "/home/data/backend-app:/home/data"
```

### 4. 注意事项

> ⚠️ **容器路径必须与 jar 的日志配置一致**

挂载的容器路径需和 Spring Boot 的 `logback-spring.xml` / `application.yml` 中配置的日志输出目录一致，否则日志不会写入挂载目录。

```xml
<!-- logback-spring.xml 示例 -->
<property name="LOG_HOME" value="/home/logs" />  <!-- 与 -v 的容器路径一致 -->
```

```yaml
# application.yml 示例
logging:
  file:
    path: /home/logs   # 与 -v 的容器路径一致
```

> ⚠️ **宿主机路径需存在或允许 Docker 自动创建**

- Docker 默认会自动创建挂载的宿主机目录（属主为 root）
- 如需指定权限，先在宿主机 `mkdir -p` 创建目录再挂载

---

## 七、常见坑 ⚠️

### 1. 不要用 `--build-arg` 传 JAVA_OPTS

`--build-arg` 只对 Dockerfile 中的 `ARG` 生效，而本 Dockerfile 用的是 `ENV`：

```dockerfile
ENV JAVA_OPTS ""     # ENV，不是 ARG
```

所以下面这条命令**不会**把参数传进容器：

```shell
# ❌ 错误：--build-arg 对 ENV 无效
docker build -f Dockerfile --build-arg JAVA_OPTS="-Xmx512m" -t backend-app:dev .
docker run -d -p 8080:8080 --name backend-app backend-app:dev
# ****** 运行命令：java -jar  /home/app.jar   ← JAVA_OPTS 为空
```

正确做法是用 `-e` 在运行时传入：

```shell
# ✅ 正确：-e 覆盖 ENV 的值
docker run -d -p 8080:8080 \
-e JAVA_OPTS="-Xmx512m" \
--name backend-app \
backend-app:dev
# ****** 运行命令：java -jar -Xmx512m /home/app.jar   ← JAVA_OPTS 已生效
```

### 对照表

| 传参方式 | 对应 Dockerfile 指令 | 生效时机 | 本 Dockerfile 是否适用 |
| --- | --- | --- | --- |
| `--build-arg JAVA_OPTS=...` | `ARG` | 构建时 | ❌ 否（用的是 ENV） |
| `-e JAVA_OPTS=...` | `ENV` | 运行时 | ✅ 是 |

---

## 八、原理说明

### 为什么 `-e` 能动态生效？

Dockerfile 第 19 行的 `CMD` 用的是 `sh -c` 执行 shell 命令：

```dockerfile
CMD ["sh", "-c", "echo \"****** 运行命令：java -jar ${JAVA_OPTS} /home/app.jar\"   &   java -jar ${JAVA_OPTS} /home/app.jar"]
```

- `["sh", "-c", "..."]`：以 exec 格式启动 shell，shell 在**容器启动时**才解析 `${JAVA_OPTS}`
- shell 解析时会读取环境变量 `JAVA_OPTS`，此时 `-e` 传入的值已覆盖 `ENV` 的默认空值
- 因此同一镜像可用不同 JVM 参数启动，无需重新构建

### 为什么用 exec 格式而不用 shell 格式？

| 格式 | 写法 | PID1 进程 | 优雅停止 |
| --- | --- | --- | --- |
| shell 格式 | `CMD java -jar app.jar` | `/bin/sh -c` | ❌ 收到 SIGTERM 不会转发给 java |
| exec 格式（本版本） | `CMD ["sh", "-c", "..."]` | `sh` → `java` | ✅ 可优雅停止 |

> exec 格式让 `java` 进程直接作为 PID1 的子进程，`docker stop` 发送 `SIGTERM` 时能被正确处理，实现优雅停止容器服务。
