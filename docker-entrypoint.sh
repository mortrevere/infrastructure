#!/usr/bin/env bash
set -euo pipefail

missing_ovh_credentials=false
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
    missing_ovh_credentials=true
  fi
done

if [[ "${missing_ovh_credentials}" == "true" ]]; then
  echo "missing OVH API credentials, running ansible only. Set OVH_APPLICATION_KEY, OVH_APPLICATION_SECRET, OVH_CONSUMER_KEY, OVH_TF_STATE_BUCKET, OVH_TF_STATE_REGION, OVH_TF_STATE_ENDPOINT, OVH_TF_STATE_ACCESS_KEY and OVH_TF_STATE_SECRET_KEY to have it run" >&2
else
  export ANSIBLE_LOCAL_TEMP="${ANSIBLE_LOCAL_TEMP:-/tmp/ansible/local}"
  export TF_DATA_DIR="${TF_DATA_DIR:-/tmp/terraform/data}"
  export TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-/tmp/terraform/plugin-cache}"
  export AWS_ACCESS_KEY_ID="${OVH_TF_STATE_ACCESS_KEY}"
  export AWS_SECRET_ACCESS_KEY="${OVH_TF_STATE_SECRET_KEY}"
  if [[ -n "${OVH_ENDPOINT:-}" ]]; then
    export TF_VAR_ovh_endpoint="${OVH_ENDPOINT}"
  fi
  mkdir -p "${ANSIBLE_LOCAL_TEMP}" "${TF_DATA_DIR}" "${TF_PLUGIN_CACHE_DIR}"

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
  terraform -chdir=/terraform apply -input=false -auto-approve
fi

export ANSIBLE_LOCAL_TEMP="${ANSIBLE_LOCAL_TEMP:-/tmp/ansible/local}"
mkdir -p "${ANSIBLE_LOCAL_TEMP}"

exec ansible-playbook playbook.yml "$@"
