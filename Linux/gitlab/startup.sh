#!/bin/bash
docker run \
    --publish 8443:443 --publish 4880:80 --publish 101122:22 \
    --name gitlab \
    --volume /www/devops/gitlab/config:/etc/gitlab \
    --volume /www/devops/gitlab/logs:/var/log/gitlab \
    --volume /www/devops/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:17.7.0-ce.0