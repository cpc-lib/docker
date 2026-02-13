#!/bin/bash

set -eu

echo "================== ↓↓↓↓↓↓ 查询docker容器日志大小 ↓↓↓↓↓↓ ================"

logs=$(find /var/lib/docker/containers/ -name '*-json.log*')

for log in $logs
do
    ls -lh $log
done

echo "===================================================================="
