# ELK 7.17.3 (ES 3节点 + Kibana + Logstash) - 开启账号密码、无证书（HTTP/Transport 明文）

账号：elastic  
密码：cpc!23#@

## 你报错的原因
你跑的是 Elasticsearch 7.17.3，但 `xpack.security.autoconfiguration.enabled` 是 8.x 才有的配置项，7.17 会报 unknown setting。

## 启动前置
Linux/WSL2 必须：
```bash
sudo sysctl -w vm.max_map_count=262144
```

## 如果你之前启动过（已有 volumes）
改密码不会生效，建议重置：
```bash
docker compose down -v
docker compose up -d
```
