#!/bin/bash

set -euo pipefail
REGISTRY="${REGISTRY:-btungut}"
TAG="${TAG:-latest}"

UBUNTU_BASE_IMAGE="${UBUNTU_BASE_IMAGE:-ubuntu}"
UBUNTU_BASE_IMAGE_TAG="${UBUNTU_BASE_IMAGE_TAG:-20.04}"
TARGETARCH="${TARGETARCH:-linux-x64}"
VSTS_AGENT_VERSION="${VSTS_AGENT_VERSION:-4.251.0}"

docker build ./src \
    --build-arg ARG_UBUNTU_BASE_IMAGE=${UBUNTU_BASE_IMAGE} \
    --build-arg ARG_UBUNTU_BASE_IMAGE_TAG=${UBUNTU_BASE_IMAGE_TAG} \
    --build-arg ARG_TARGETARCH=${TARGETARCH} \
    --build-arg ARG_VSTS_AGENT_VERSION=${VSTS_AGENT_VERSION} \
    -f ./Dockerfile \
    -t ${REGISTRY}/azure-devops-agent:${TAG} \
    --progress=plain \
    "$@"