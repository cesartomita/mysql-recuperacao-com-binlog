#!/bin/bash

echo "Parando e removendo os containers..."
docker-compose down

echo "Apagando volumes locais..."
rm -rf ./.mysql_production
rm -rf ./.mysql_recovery
rm -rf ./binlogs_recovery

echo "Subindo containers novamente..."
docker-compose up -d --build

echo "Ambiente reiniciado com sucesso!"

sleep 5