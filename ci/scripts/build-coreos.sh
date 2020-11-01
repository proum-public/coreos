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
  echo "        -c --config-repo:       URL to git repository with fedora coreos config"
  echo "                                (default: ${DEFAULT_CONFIG_REPO}) (ENV: CONFIG_REPO)"
  echo "        -c --cosa-config:       Path to cosa config directory"
  echo "                                (default: ${DEFAULT_COSA_CONFIG}) (ENV: COSA_CONFIG)"
  echo ""
  echo "environment variables:"
  echo "        CONFIG_REPO:            URL to git repository with fedora coreos config"
  echo "                                (default: ${DEFAULT_CONFIG_REPO}"
  echo "        COSA_CONFIG:            Path to cosa config (default: ${DEFAULT_COSA_CONFIG})"
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

# Build image
bash ${COSA_CONFIG}/build.sh -c "${CONFIG_REPO}"