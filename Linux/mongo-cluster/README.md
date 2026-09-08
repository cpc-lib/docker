# 启动 & 初始化副本集 + 创建 root 用户

docker compose up -d

## 执行初始化脚本（只需要一次）
docker cp ./scripts/init-rs.js mongo1:/init-rs.js
docker exec -it mongo1 mongosh /init-rs.js

# 验证
docker exec -it mongo1 mongosh -u root -p root123456 --authenticationDatabase admin --eval "rs.status().members.map(m=>({name:m.name,stateStr:m.stateStr}))"

# 连接字符串
mongodb://root:root123456@localhost:27017,localhost:27018,localhost:27019/?replicaSet=rs0&authSource=admin
