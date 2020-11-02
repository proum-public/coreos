#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"

DEFAULT_COSA_CONFIG="${SCRIPT_DIR}/../cosa"
DEFAULT_CONFIG_REPO="https://github.com/proum-public/fedora-coreos-config"

# check prerequisites
for cmd in gcloud
do
    command -v ${cmd} > /dev/null || {  echo >&2 "${cmd} must be installed - exiting..."; exit 1; }
done

function usage() {
  echo "usage: $0"
  echo ""
  echo "        -c --config-repo:               URL to git repository with fedora coreos config"
  echo "                                        (default: ${DEFAULT_CONFIG_REPO}) (ENV: CONFIG_REPO)"
  echo ""
  echo "        -c --cosa-config:               Path to cosa config directory"
  echo "                                        (default: ${DEFAULT_COSA_CONFIG}) (ENV: COSA_CONFIG)"
  echo ""
  echo "        -r --run-id:                    ID of run (e.g. Github actions run id)"
  echo "                                        (required) (ENV: RUN_ID)"
  echo ""
  echo "        -p --gcp-project:               Google cloud project"
  echo "                                        (default: proum-coreos-assemble) (ENV: GCP_PROJECT)"
  echo ""
  echo "environment variables:"
  echo "        CONFIG_REPO:                    URL to git repository with fedora coreos config"
  echo "                                        (default: ${DEFAULT_CONFIG_REPO}"
  echo "        COSA_CONFIG:                    Path to cosa config (default: ${DEFAULT_COSA_CONFIG})"
  echo "        RUN_ID:                         ID of run (e.g. Github actions run id) (required)"
  echo "        GOOGLE_APPLICATION_CREDENTIALS: GCP application credentials (required)"
  echo "        GCP_PROJECT:                    GCP project (default: proum-coreos-assemble)"
}

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --config-repo|-c)
        export CONFIG_REPO="$2"
        shift
        shift
        ;;
        --cosa-config|-c)
        export COSA_CONFIG="$2"
        shift
        shift
        ;;
        --run-id|-r)
        export RUN_ID="$2"
        shift
        shift
        ;;
        --gcp-project|-p)
        export GCP_PROJECT="$2"
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

if [[ -z ${CONFIG_REPO} ]]; then
    export CONFIG_REPO="${DEFAULT_CONFIG_REPO}"
fi

if [[ -z ${COSA_CONFIG} ]]; then
    export COSA_CONFIG="${SCRIPT_DIR}/../cosa"
fi

if [[ -z ${RUN_ID} ]]; then
    echo "RUN_ID not defined!"
    usage
    exit 1
fi

if [[ -z ${GOOGLE_APPLICATION_CREDENTIALS} ]]; then
    echo "GOOGLE_APPLICATION_CREDENTIALS not defined!"
    usage
    exit 1
fi

if [[ -z ${GCP_PROJECT} ]]; then
    export GCP_PROJECT=proum-coreos-assemble
fi

# Create temp dir
export CLOUDSDK_CONFIG=$(pwd)/.gcloud
mkdir -p "${CLOUDSDK_CONFIG}"

# Fetch temporary access token
gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}

# Set project
gcloud config set project "${GCP_PROJECT}"

# Build image
bash ${COSA_CONFIG}/build.sh -c "${CONFIG_REPO}"