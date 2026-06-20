#!/usr/bin/env bash
set -euo pipefail

run_ansible() {
  export ANSIBLE_LOCAL_TEMP="${ANSIBLE_LOCAL_TEMP:-/tmp/ansible/local}"
  export ANSIBLE_HOST_KEY_CHECKING="${ANSIBLE_HOST_KEY_CHECKING:-True}"
  export ANSIBLE_RETRY_FILES_ENABLED="${ANSIBLE_RETRY_FILES_ENABLED:-False}"
  mkdir -p "${ANSIBLE_LOCAL_TEMP}"

  exec ansible-playbook playbook.yml "$@"
}

run_terraform() {
  local missing_vars=()
  for ovh_var in \
    OVH_APPLICATION_KEY \
    OVH_APPLICATION_SECRET \
    OVH_CONSUMER_KEY \
    OVH_TF_STATE_BUCKET \
    OVH_TF_STATE_REGION \
    OVH_TF_STATE_ENDPOINT \
    OVH_TF_STATE_ACCESS_KEY \
    OVH_TF_STATE_SECRET_KEY; do
    if [[ -z "${!ovh_var:-}" ]]; then
      missing_vars+=("${ovh_var}")
    fi
  done

  if (( ${#missing_vars[@]} > 0 )); then
    printf 'missing required Terraform environment variables: %s\n' "${missing_vars[*]}" >&2
    exit 1
  fi

  export TF_DATA_DIR="${TF_DATA_DIR:-/tmp/terraform/data}"
  export TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-/tmp/terraform/plugin-cache}"
  export AWS_ACCESS_KEY_ID="${OVH_TF_STATE_ACCESS_KEY}"
  export AWS_SECRET_ACCESS_KEY="${OVH_TF_STATE_SECRET_KEY}"
  if [[ -n "${OVH_ENDPOINT:-}" ]]; then
    export TF_VAR_ovh_endpoint="${OVH_ENDPOINT}"
  fi
  mkdir -p "${TF_DATA_DIR}" "${TF_PLUGIN_CACHE_DIR}"

  cat > /tmp/terraform/backend.hcl <<EOF
bucket = "${OVH_TF_STATE_BUCKET}"
key    = "${OVH_TF_STATE_KEY:-infrastructure/terraform.tfstate}"
region = "${OVH_TF_STATE_REGION}"

endpoints = {
  s3 = "${OVH_TF_STATE_ENDPOINT}"
}

skip_credentials_validation = true
skip_metadata_api_check     = true
skip_region_validation      = true
skip_requesting_account_id  = true
skip_s3_checksum            = true
use_path_style              = true
EOF

  terraform -chdir=/terraform init -input=false -lockfile=readonly -backend-config=/tmp/terraform/backend.hcl

  if (( $# == 0 )); then
    exec terraform -chdir=/terraform apply -input=false -auto-approve
  fi

  exec terraform -chdir=/terraform "$@"
}

case "${1:-}" in
  ansible)
    shift
    run_ansible "$@"
    ;;
  terraform)
    shift
    run_terraform "$@"
    ;;
  "")
    echo "usage: docker-entrypoint.sh ansible [args...] | terraform [args...]" >&2
    exit 2
    ;;
  *)
    exec "$@"
    ;;
esac
