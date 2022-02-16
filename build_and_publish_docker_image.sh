#!/bin/bash

app=postgres-backup
version=1.0.0
user=jhaeger

echo "login to registry"
docker login

echo "setup multi-arch builder"
docker buildx rm multi-arch
docker buildx create --name multi-arch --platform linux/arm64,linux/amd64 --use

echo "creating docker images for $app-$version and push to registry"
docker buildx build --platform linux/arm64,linux/amd64 --tag=$user/$app:$version --tag=$user/$app:latest --push .

echo "restore default builder"
docker buildx use default
docker buildx rm multi-arch
