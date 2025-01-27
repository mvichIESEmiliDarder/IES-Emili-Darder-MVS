#!/bin/bash

# Lista de contenedores o servicios de Docker Compose que deseas detener
compose_files=(
    "/home/marti/docker/wireguard/docker-compose.yml"
)

for file in "${compose_files[@]}"
do
    echo "Deteniendo contenedores para $(dirname "$file")..."
    docker compose -f "$file" down
    echo "Contenedores detenidos para $(dirname "$file")."
done
