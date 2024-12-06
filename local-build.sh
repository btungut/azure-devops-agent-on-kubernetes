#!/bin/bash

set -euo pipefail
REGISTRY="${REGISTRY:-btungut}"
TAG="${TAG:-latest}"

docker build ./src \
    -f ./Dockerfile \
    -t ${REGISTRY}/azure-devops-agent:${TAG} \
    --progress=plain