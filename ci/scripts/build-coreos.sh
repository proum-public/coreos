#!/usr/bin/env bash
set -xeo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"
TERM=xterm

# check prerequisites
for cmd in packer
do
    command -v ${cmd} > /dev/null || {  echo >&2 "${cmd} must be installed - exiting..."; exit 1; }
done

function usage() {
  echo "usage: $0"
  echo ""
  echo "        -c --packer-config:     Path to packer config directory"
  echo "                                (default: ci/packer) (ENV: PACKER_CONFIG)"
  echo ""
  echo "environment variables:"
  echo "        PACKER_CONFIG:          Path to packer config (default: ci/packer)"
}

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --packer-config|-c)
        export PACKER_CONFIG="$2"
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

if [[ -z ${PACKER_CONFIG} ]]; then
    export PACKER_CONFIG=ci/packer
fi

# Build image
cd "${PACKER_CONFIG}" \
  && find . -maxdepth 1 -name '*.json' -print0 | xargs -t0n1 packer build -force