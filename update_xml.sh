#!/bin/bash
export cdh=hadoop-2.6.0-cdh5.14.4
export hivehome=hive-1.1.0-cdh5.14.4

function update_hadoop_configs {
  for file in slaves hadoop-env.sh core-site.xml hdfs-site.xml mapred-site.xml yarn-site.xml yarn-env.sh fair-scheduler.xml
    do
      scp /kkb/soft/hadoop-cluster-on-aws/configs/$file $1:/kkb/install/$cdh/etc/hadoop/$file
      echo Updated $file on $1
    done
  chmod 755 /kkb/install/$cdh/etc/hadoop/*.sh
}

function update_hive_configs {
  for file in hive-env.sh hive-site.xml hive-log4j.properties
    do
      scp /kkb/soft/hadoop-cluster-on-aws/configs/$file $1:/kkb/install/$hivehome/conf
      echo Updated $file on $1
    done
  chmod 755 /kkb/install/$hivehome/conf/*.sh
}

for host in node01 node02 node03
do
  update_hadoop_configs $host

  if [$host == 'node02']
    then update_hive_configs $host
  fi
done

