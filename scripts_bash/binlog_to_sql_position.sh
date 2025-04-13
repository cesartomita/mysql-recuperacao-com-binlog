#!/bin/bash

# Processa os arquivos binlog.000001 e binlog.000002 normalmente
winpty docker exec -it mysql_binlog_recovery \
  bash -c "mysqlbinlog \
  /var/lib/mysql/restore_binlog/binlog.000001 \
  /var/lib/mysql/restore_binlog/binlog.000002 | tee /var/lib/mysql/RESTORE.sql"

# Processa o arquivo binlog.000003 até a posição especificada
winpty docker exec -it mysql_binlog_recovery \
  bash -c "mysqlbinlog \
  --stop-position=4732398 \
  /var/lib/mysql/restore_binlog/binlog.000003 | tee -a /var/lib/mysql/RESTORE.sql"

# No primeiro comando, o tee grava a saída no arquivo /var/lib/mysql/RESTORE.sql e exibe no terminal.
# No segundo comando, o tee -a (modo de anexar) adiciona a saída ao final do arquivo /var/lib/mysql/RESTORE.sql e exibe no terminal.

echo "RESTORE.sql criado com sucesso!"

sleep 5