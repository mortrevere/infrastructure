#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="${INFRASTRUCTURE_IMAGE_NAME:-infrastructure:local}"

"${SCRIPT_DIR}/build.sh"

docker_args=(
  --rm
  -it
  -w /terraform
  -v "${SCRIPT_DIR}/terraform:/terraform:ro"
)

for ovh_var in \
  OVH_APPLICATION_KEY \
  OVH_APPLICATION_SECRET \
  OVH_CONSUMER_KEY \
  OVH_ENDPOINT \
  OVH_TF_STATE_BUCKET \
  OVH_TF_STATE_KEY \
  OVH_TF_STATE_REGION \
  OVH_TF_STATE_ENDPOINT \
  OVH_TF_STATE_ACCESS_KEY \
  OVH_TF_STATE_SECRET_KEY; do
  if [[ -n "${!ovh_var:-}" ]]; then
    docker_args+=(-e "${ovh_var}")
  fi
done

exec docker run "${docker_args[@]}" "${IMAGE_NAME}" terraform "$@"
