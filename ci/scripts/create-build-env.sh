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
  echo "        -r --run-id:            ID of run (e.g. Github actions run id)"
  echo "                                (required) (ENV: RUN_ID)"
  echo ""
  echo "environment variables:"
  echo "        TERRAFORM_CONFIG:       Path to terraform config (default: ci/terraform)"
  echo "        RUN_ID:                 ID of run (e.g. Github actions run id) (required)"
}

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --terraform-config|-c)
        export TERRAFORM_CONFIG="$2"
        shift
        shift
        ;;
        --run-id|-r)
        export RUN_ID="$2"
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

if [[ -z ${RUN_ID} ]]; then
    echo "RUN_ID not defined!"
    usage
    exit 1
fi

# Apply terraform
cd ${TERRAFORM_CONFIG}

# Init terraform
terraform init

# Create or select run workspace
terraform workspace select "run-${RUN_ID}" || terraform workspace new "run-${RUN_ID}"

# Create
terraform apply -auto-approve
