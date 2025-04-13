#!/bin/bash

echo "Copiando arquivos binlog de mysql_binlog_production para o host..."

mkdir -p ./binlogs_recovery
docker cp mysql_binlog_production:/var/lib/mysql/binlog.000001 ./binlogs_recovery/binlog.000001
docker cp mysql_binlog_production:/var/lib/mysql/binlog.000002 ./binlogs_recovery/binlog.000002
docker cp mysql_binlog_production:/var/lib/mysql/binlog.000003 ./binlogs_recovery/binlog.000003
docker cp mysql_binlog_production:/var/lib/mysql/binlog.000004 ./binlogs_recovery/binlog.000004

echo "Copiando arquivos binlog de host para mysql_binlog_recovery..."

docker cp ./binlogs_recovery/. mysql_binlog_recovery:/var/lib/mysql/restore_binlog

sleep 5