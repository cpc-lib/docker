#!/bin/bash

# 在执行过程中若遇到使用了未定义的变量或命令返回值为非零，将直接报错退出
set -eu

# 源镜像
images=(
  mysql:5.7
  nacos-server:2.0.3
)

# 目标镜像仓库
target_image_registry_prefix="registry.cn-hangzhou.aliyuncs.com/snow-io/"

# 循环
for image_name in ${images[@]} ; do
  echo "********************************************************************"
  docker pull ${image_name}
  # 重命名镜像
  docker tag ${image_name} ${target_image_registry_prefix}${image_name}
  # 推送镜像
  docker push ${target_image_registry_prefix}${image_name}

  echo "*** [√] ${target_image_registry_prefix}${image_name}"
done

echo "finish ..."