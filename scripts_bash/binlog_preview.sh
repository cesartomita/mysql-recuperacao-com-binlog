#!/bin/bash

echo "Criando RESTORE_PREVIEW_000001.sql..."

docker exec -i mysql_binlog_recovery bash -c \
  "mysqlbinlog --base64-output=DECODE-ROWS --verbose \
  /var/lib/mysql/restore_binlog/binlog.000001 > /var/lib/mysql/RESTORE_PREVIEW_000001.sql"

echo "Criando RESTORE_PREVIEW_000002.sql..."

docker exec -i mysql_binlog_recovery bash -c \
  "mysqlbinlog --base64-output=DECODE-ROWS --verbose \
  /var/lib/mysql/restore_binlog/binlog.000002 > /var/lib/mysql/RESTORE_PREVIEW_000002.sql"

echo "Criando RESTORE_PREVIEW_000003.sql..."

docker exec -i mysql_binlog_recovery bash -c \
  "mysqlbinlog --base64-output=DECODE-ROWS --verbose \
  /var/lib/mysql/restore_binlog/binlog.000003 > /var/lib/mysql/RESTORE_PREVIEW_000003.sql"

echo "Criando RESTORE_PREVIEW_000004.sql..."

docker exec -i mysql_binlog_recovery bash -c \
  "mysqlbinlog --base64-output=DECODE-ROWS --verbose \
  /var/lib/mysql/restore_binlog/binlog.000004 > /var/lib/mysql/RESTORE_PREVIEW_000004.sql"

sleep 5