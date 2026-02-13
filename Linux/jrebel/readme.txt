#进行容器的构建
docker build -t jrebel:latest .

#登录推送进行的阿里云的个人镜像仓库
docker login --username=snow-io registry.cn-hangzhou.aliyuncs.com
docker tag jrebel:latest registry.cn-hangzhou.aliyuncs.com/snow-io/jrebel:latest
docker push registry.cn-hangzhou.aliyuncs.com/snow-io/jrebel:latest

#推送到dockerhub
docker login -u g2plus
docker tag jrebel:latest g2plus/jrebel:latest
docker push g2plus/jrebel:latest
