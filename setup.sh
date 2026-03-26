#!/bin/bash

echo "Starting setup..."

# Check is docker is installed
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

echo "Cleaning up old containers..."
docker compose down -v

echo "Building and launching containers..."
docker compose up --build -d

# Waiting because db may take a few seconds to start
echo "Waiting for services to stabilize..."
sleep 10

echo "========================================="
echo "          Application is ready!"
echo "         URL: http://localhost:3000"
echo "========================================="