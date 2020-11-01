#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"

# check prerequisites
for cmd in terraform
do
    command -v ${cmd} > /dev/null || {  echo >&2 "${cmd} must be installed - exiting..."; exit 1; }
done

function usage() {
  echo "usage: $0"
  echo ""
  echo "        -c --terraform-config:  Path to terraform config directory"
  echo "                                (default: ci/terraform) (ENV: TERRAFORM_CONFIG)"
  echo ""
  echo "environment variables:"
  echo "        TERRAFORM_CONFIG:       Path to terraform config (default: ci/terraform)"
}

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --terraform-config|-c)
        export TERRAFORM_CONFIG="$2"
        shift
        shift
        ;;
        --help|-h|help)
        usage
        exit 0
        ;;
        *)
        shift
        shift
    esac
done

if [[ -z ${TERRAFORM_CONFIG} ]]; then
    export TERRAFORM_CONFIG=ci/terraform
fi

# Apply terraform
cd ${TERRAFORM_CONFIG}

terraform init

terraform apply -auto-approve