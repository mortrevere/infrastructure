#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${ANSIBLE_IMAGE_NAME:-below-black-ansible:local}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

docker build -t "${IMAGE_NAME}" "${SCRIPT_DIR}"

docker_args=(
  --rm
  -it
  -w /ansible
  -e TERM="${TERM:-xterm}"
  -e ANSIBLE_FORCE_COLOR="${ANSIBLE_FORCE_COLOR:-true}"
  -e ANSIBLE_WWW_SOURCE_ROOT=/workspace
  -v "${SCRIPT_DIR}/ansible.cfg:/ansible/ansible.cfg:ro"
  -v "${SCRIPT_DIR}/inventory.ini:/ansible/inventory.ini:ro"
  -v "${SCRIPT_DIR}/playbook.yml:/ansible/playbook.yml:ro"
  -v "${SCRIPT_DIR}/README.md:/ansible/README.md:ro"
  -v "${SCRIPT_DIR}/group_vars:/ansible/group_vars:ro"
  -v "${SCRIPT_DIR}/templates:/ansible/templates:ro"
  -v "${SCRIPT_DIR}/terraform:/terraform:ro"
  -v "${WORKSPACE_DIR}:/workspace:ro"
  --add-host leo.surf:91.134.140.52
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

if [[ -d "${HOME}/.ssh" ]]; then
  docker_args+=(-v "${HOME}/.ssh:/root/.ssh:ro")
fi

if [[ -n "${SSH_AUTH_SOCK:-}" && -S "${SSH_AUTH_SOCK}" ]]; then
  docker_args+=(
    -e SSH_AUTH_SOCK="${SSH_AUTH_SOCK}"
    -v "${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK}"
  )
fi

exec docker run "${docker_args[@]}" "${IMAGE_NAME}" "$@"
