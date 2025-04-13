#!/bin/bash

echo "Restaurando o arquivo RESTORE.sql no banco de dados de recuperação..."

winpty docker exec -i mysql_binlog_recovery bash -c "
  export MYSQL_PWD='pass123';
  mysql -uroot -e 'CREATE DATABASE IF NOT EXISTS demo;';
  mysql -uroot demo --verbose --force < /var/lib/mysql/RESTORE.sql
"
echo "Restauração concluída com sucesso!"

read