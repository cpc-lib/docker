mkdir -p data/config data/downloads

sudo chown -R 1000:1000 data/config data/downloads

sudo chmod -R u+rwX data/config data/downloads

# 检查配置
docker compose config

# 拉取镜像
docker compose pull

# 启动
docker compose up -d

# 查看运行情况
docker compose ps

# 查看日志
docker compose logs -f --tail=100 qbittorrent

首次启动时，可从容器日志查看 WebUI 的临时管理员密码。用户名通常为 admin，登录后应立即设置自己的密码。


#设置密码
Tools->Options->WebUI

#重启qbittorrent
docker compose stop qbittorrent
docker compose up -d qbittorrent