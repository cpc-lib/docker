# MySQL 一主两从（Docker Compose）

## 端口映射
- master: 3307
- slave1: 3308
- slave2: 3309

## 网络
- 子网：172.30.0.0/16（避免常见 192.168.x / 10.x 冲突）

## 启动
docker compose up -d

## Master 上创建复制账号
mysql -h127.0.0.1 -P3306 -uroot -proot123456

CREATE USER 'repl'@'%' IDENTIFIED BY '123456';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'repl'@'%';
SHOW MASTER STATUS;

## Slave 上配置复制
STOP SLAVE;

CHANGE MASTER TO
  MASTER_HOST='mysql-master',
  MASTER_USER='repl',
  MASTER_PASSWORD='123456',
  MASTER_PORT=3306,
  MASTER_LOG_FILE='mysql-bin.000003',
  MASTER_LOG_POS=615;

START SLAVE;
SHOW SLAVE STATUS\G

## Master执行一下语句
CREATE TABLE `t_user` (
`id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
`uid` VARCHAR(64) NOT NULL COMMENT '用户ID(业务)',
`phone` VARCHAR(32) NULL COMMENT '手机号',
`email` VARCHAR(128) NULL COMMENT '邮箱',
`password_hash` VARCHAR(255) NOT NULL COMMENT '密码hash',
`salt` VARCHAR(64) NULL COMMENT '盐(可选)',
`status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1正常 0禁用',
`last_login_at` DATETIME NULL COMMENT '最后登录时间',

`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
`updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
`deleted` TINYINT NOT NULL DEFAULT 0,
`version` BIGINT NOT NULL DEFAULT 0,

PRIMARY KEY (`id`),
UNIQUE KEY `uk_uid` (`uid`),
UNIQUE KEY `uk_phone` (`phone`),
UNIQUE KEY `uk_email` (`email`),
KEY `idx_status_updated` (`status`, `updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

## 注意点容器重启了需要重新配置


