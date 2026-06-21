#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${INFRASTRUCTURE_IMAGE_NAME:-infrastructure:local}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

docker build -t "${IMAGE_NAME}" "${SCRIPT_DIR}"
