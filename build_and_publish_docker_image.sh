#!/bin/bash

if [ $# -eq 0 ]; then
 echo "Please call script with version string to use as argument!"
 echo "e.g.: ./build_and_publish_docker_image.sh 1.0.0"
 exit 1
fi

app=postgres-backup
version=$1
user=jhaeger

echo "login to registry"
docker login

echo "setup multi-arch builder"
docker buildx rm multi-arch
docker buildx create --name multi-arch --platform linux/arm64,linux/amd64 --use

echo "creating docker images for $app-$version and push to registry"
docker buildx build \
  --platform linux/arm64,linux/amd64 \
  --tag=$user/$app:$version --tag=$user/$app:latest \
  --build-arg BUILD_DATE=$(date +%F) \
  --build-arg BUILD_VERSION=$version \
  --push .

echo "restore default builder"
docker buildx use default
docker buildx rm multi-arch
