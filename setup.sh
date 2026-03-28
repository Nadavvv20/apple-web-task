#!/bin/bash
# Run this script if you wish to run the app localy on your machine.

echo "Starting setup..."

# Check is docker is installed
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

echo "Cleaning up old containers..."
docker compose down -v

echo "Building and launching containers..."
# Provide fallbacks for the local environment so docker-compose doesn't complain about empty variables
export DOCKER_USERNAME=${DOCKER_USERNAME:-localdev}
export IMAGE_TAG=${IMAGE_TAG:-latest}

docker compose up --build -d

# Waiting because db may take a few seconds to start
echo "Waiting for services to stabilize..."
sleep 10

echo "========================================="
echo "          Application is ready!"
echo "          URL: http://localhost"
echo "========================================="