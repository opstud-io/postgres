#!/bin/bash
set -e

EXTENSION_NAME=$1
PG_VERSION=${2:-16}
WORK_DIR="build/${EXTENSION_NAME}"

# Load extension config
REPO_URL=$(yq e ".extensions.${EXTENSION_NAME}.repository" extensions.yml)
BRANCH=$(yq e ".extensions.${EXTENSION_NAME}.branch" extensions.yml)

if [ -z "$REPO_URL" ]; then
    echo "Extension ${EXTENSION_NAME} not found in extensions.yml"
    exit 1
fi

# Create work directory
mkdir -p "$WORK_DIR"

# Clone repository if not exists
if [ ! -d "$WORK_DIR/.git" ]; then
    git clone --depth 1 -b "$BRANCH" "$REPO_URL" "$WORK_DIR"
else
    cd "$WORK_DIR"
    git fetch origin "$BRANCH"
    git reset --hard "origin/$BRANCH"
    cd -
fi

# Read pgrx version from Cargo.toml
cd "$WORK_DIR"
PGRX_VERSION=$(grep -m1 'pgrx = "[^"]*"' Cargo.toml | grep -o '"[^"]*"' | tr -d '"')
if [ -z "$PGRX_VERSION" ]; then
    echo "Unable to find pgrx version in Cargo.toml"
    exit 1
fi

DOCKER_TAG="local/pgrx:${PG_VERSION}-${PGRX_VERSION}"

# Build Docker image with correct PGRX version
echo "Building Docker image with PGRX version ${PGRX_VERSION}..."
docker build \
    --build-arg PSQL_SUPPORT_VERSION=${PG_VERSION} \
    --build-arg PGRX_VERSION=${PGRX_VERSION} \
    -t ${DOCKER_TAG} \
    https://github.com/shencangsheng/pgrx-docker.git#main

# Build extension
docker run --rm \
    -v $(pwd):/usr/src/app \
    -e PSQL_VERSION=$PG_VERSION \
    ${DOCKER_TAG}

# Package extension
VERSION=$(grep -m1 '^version = "[^"]*"' Cargo.toml | grep -o '"[^"]*"' | tr -d '"')
mkdir -p artifacts
tar -czf artifacts/${EXTENSION_NAME}-pg${PG_VERSION}-${VERSION}.tar.gz \
    -C target/release/${EXTENSION_NAME}-pg${PG_VERSION}/.pgrx/${PG_VERSION}/pgrx-install/ .

# Copy artifacts to main artifacts directory
mkdir -p ../../artifacts
cp artifacts/*.tar.gz ../../artifacts/

echo "Build complete! Package: artifacts/${EXTENSION_NAME}-pg${PG_VERSION}-${VERSION}.tar.gz"