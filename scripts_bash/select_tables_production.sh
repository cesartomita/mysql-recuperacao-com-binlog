#!/bin/bash

source .env

docker exec -i mysql_binlog_production bash -c "
  export MYSQL_PWD='${MYSQL_ROOT_PASSWORD}';
  mysql -uroot -e \"
    USE demo;
    SELECT * FROM (SELECT * FROM clientes ORDER BY id DESC LIMIT 5) AS ultimos_clientes ORDER BY id ASC;
    SELECT * FROM (SELECT * FROM vendedores ORDER BY id DESC LIMIT 5) AS ultimos_vendedores ORDER BY id ASC;
    SELECT * FROM (SELECT * FROM diretores ORDER BY id DESC LIMIT 5) AS ultimos_diretores ORDER BY id ASC;
  \"
"

echo "Pressione [Enter] para sair..."

read