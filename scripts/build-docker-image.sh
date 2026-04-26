#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="${IMAGE_NAME:-axonhub}"
IMAGE_TAG="${IMAGE_TAG:-local}"
PLATFORM="${PLATFORM:-linux/amd64}"
VERSION_FILE="${ROOT_DIR}/internal/build/VERSION"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required but was not found in PATH" >&2
  exit 1
fi

if ! docker buildx version >/dev/null 2>&1; then
  echo "docker buildx is required but is not available" >&2
  exit 1
fi

if [[ -f "${VERSION_FILE}" ]]; then
  VERSION="$(tr -d '[:space:]' < "${VERSION_FILE}")"
else
  VERSION="dev"
fi

if [[ -z "${VERSION}" ]]; then
  VERSION="dev"
fi

echo "Building ${IMAGE_NAME}:${IMAGE_TAG} for ${PLATFORM}"

docker buildx build \
  --platform "${PLATFORM}" \
  --build-arg BUILDPLATFORM="${PLATFORM}" \
  --tag "${IMAGE_NAME}:${IMAGE_TAG}" \
  --load \
  "${ROOT_DIR}"
