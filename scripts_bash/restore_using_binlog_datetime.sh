#!/bin/bash

echo "Restaurando os binlogs diretamente no banco de dados de recuperação..."

winpty docker exec -i mysql_binlog_recovery bash -c "
  export MYSQL_PWD='pass123';

  mysql -uroot -e 'CREATE DATABASE IF NOT EXISTS demo;';

  mysqlbinlog /var/lib/mysql/restore_binlog/binlog.000001 | mysql -uroot demo --verbose --force;
  mysqlbinlog /var/lib/mysql/restore_binlog/binlog.000002 | mysql -uroot demo --verbose --force;
  mysqlbinlog --stop-datetime='2025-04-12 20:30:32' /var/lib/mysql/restore_binlog/binlog.000003 | mysql -uroot demo --verbose --force;
"

echo "Restauração dos binlogs finalizada!"
read
