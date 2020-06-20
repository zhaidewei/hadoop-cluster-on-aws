CREATE DATABASE IF NOT EXISTS game_center;

USE game_center;

-- ODS Layer Tables

CREATE TABLE IF NOT EXISTS ods_user_login(
plat_id            STRING     COMMENT '平台id',
server_id          INT        COMMENT '区服id',
channel_id         STRING     COMMENT '渠道',
user_id            STRING     COMMENT '用户ID',
role_id            STRING     COMMENT '角色ID',
role_name          STRING     COMMENT '角色名称',
client_ip          STRING     COMMENT '客户端IP',
event_time         INT        COMMENT '事件时间',
op_type            STRING     COMMENT '操作类型(1:登录,-1登出)',
online_time        INT        COMMENT '在线时长(s)',
operating_system   STRING     COMMENT '操作系统名称',
operating_version  STRING     COMMENT '操作系统版本',
device_brand       STRING     COMMENT '设备型号',
device_type        STRING     COMMENT '设备品牌'
)
COMMENT '游戏登录登出'
PARTITIONED BY(part_date DATE)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS INPUTFORMAT
      'com.hadoop.mapred.DeprecatedLzoTextInputFormat'
    OUTPUTFORMAT
      'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat';

CREATE TABLE IF NOT EXISTS tmp_ods_user_login(
plat_id            STRING     COMMENT '平台id',
server_id          INT        COMMENT '区服id',
channel_id         STRING     COMMENT '渠道',
user_id            STRING     COMMENT '用户ID',
role_id            STRING     COMMENT '角色ID',
role_name          STRING     COMMENT '角色名称',
client_ip          STRING     COMMENT '客户端IP',
event_time         INT        COMMENT '事件时间',
op_type            STRING     COMMENT '操作类型(1:登录,-1登出)',
online_time        INT        COMMENT '在线时长(s)',
operating_system   STRING     COMMENT '操作系统名称',
operating_version  STRING     COMMENT '操作系统版本',
device_brand       STRING     COMMENT '设备型号',
device_type        STRING     COMMENT '设备品牌'
)
COMMENT '游戏登录登出-临时表，用于将数据通过动态分区载入ods_user_login中'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
