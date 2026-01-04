#!/bin/bash
set -e

echo "Present working directory: $(pwd)"
WORKING_DIR=./ansible
cp .env "${WORKING_DIR}/.env"
docker compose -f ${WORKING_DIR}/docker-compose.yml up --build --force-recreate