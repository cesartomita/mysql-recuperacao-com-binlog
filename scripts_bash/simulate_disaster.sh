#!/bin/bash

source .env

echo "Simulando desastre..."

docker exec -i mysql_binlog_production bash -c '
  export MYSQL_PWD="'${MYSQL_ROOT_PASSWORD}'";
  mysql -uroot -e "
    USE demo;
    SELECT 'Apagando tabela diretores...';
    DROP TABLE diretores;
    SELECT 'Excluindo registros da tabela vendedores...';
    DELETE FROM vendedores WHERE id > 1;
    SELECT 'Atualizando registros da tabela clientes...';
    UPDATE clientes SET nome = '\''CLIENTE X'\'';
  "
'

echo "Simulando desastre com sucesso!"

sleep 5