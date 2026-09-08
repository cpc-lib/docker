# 拉取nginx基础镜像
FROM nginx:1.21.1

# 维护者信息
MAINTAINER cpc-lib

# 将本地打包后的dist文件复制到 `/usr/share/nginx/html/` 这个目录下面
# tips: 本地需先执行打包命令产出 dist/ 目录
#   - Vue  (vite):  npm run build   -> dist/
#   - React (vite): npm run build   -> dist/
#   - React (CRA):  npm run build   -> build/  需将下行 dist/ 改为 build/
COPY dist/  /usr/share/nginx/html/

# 用本地配置文件替换nginx默认server配置，支持前端单页应用路由刷新
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 对外暴漏的端口号
# [注：EXPOSE指令只是声明容器运行时提供的服务端口，给读者看有哪些端口，在运行时只会开启程序自身的端口！！]
EXPOSE 80

# 启动nginx容器
CMD ["nginx", "-g", "daemon off;"]
