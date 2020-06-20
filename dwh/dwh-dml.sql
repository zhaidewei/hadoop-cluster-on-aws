-- Dynamic partition
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nostrict;
set hive.exec.max.dynamic.partitions.pernode=1000;

USE game_center;

LOAD DATA LOCAL INPATH '/kkb/install/hivedatas/ods_user_login.txt' OVERWRITE INTO TABLE tmp_ods_user_login;

-- Use LZO as output
SET hive.exec.compress.output=true;
SET mapreduce.output.fileoutputformat.compress=true;
set mapred.output.compression.codec=com.hadoop.compression.lzo.LzopCodec;

-- From temp table to ods user login table
INSERT OVERWRITE TABLE ods_user_login PARTITION(part_date)
SELECT plat_id,server_id,channel_id,user_id,role_id,role_name,client_ip,event_time,op_type,online_time,operating_system,operating_version,device_brand,device_type,from_unixtime(event_time,'yyyy-MM-dd') AS part_date
FROM TMP_ODS_USER_LOGIN;
