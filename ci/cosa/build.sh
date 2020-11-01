#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"

DEFAULT_ASSEMBLE_SCRIPT="${SCRIPT_DIR}/assemble.sh"

# check prerequisites
for cmd in gcloud
do
    command -v ${cmd} > /dev/null || {  echo >&2 "${cmd} must be installed - exiting..."; exit 1; }
done

function usage() {
  echo "usage: $0"
  echo ""
  echo "        -c --config-repo:       URL to git repository with fedora coreos config"
  echo "                                (required) (ENV: CONFIG_REPO)"
  echo "        -w --working-dir:       Path to cosa working directory"
  echo "                                (default: '\${PWD}/fcos') (ENV: WORKING_DIR)"
  echo "        -a --assemble-script:   Path to assemble script"
  echo "                                (default: ${DEFAULT_ASSEMBLE_SCRIPT}) (ENV: ASSEMBLE_SCRIPT)"
  echo ""
  echo "environment variables:"
  echo "        CONFIG_REPO:            URL to git repository with fedora coreos config (required)"
  echo "        WORKING_DIR:            Path to cosa config (default: '\${PWD}/fcos')"
  echo "        ASSEMBLE_SCRIPT:        Path to assemble script (default: ${DEFAULT_ASSEMBLE_SCRIPT})"
}

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --config-repo|-c)
        export CONFIG_REPO="$2"
        shift
        shift
        ;;
        --working-dir|-w)
        export WORKING_DIR="$2"
        shift
        shift
        ;;
        --assemble-script|-a)
        export ASSEMBLE_SCRIPT="$2"
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
    echo "CONFIG not set!"
    usage
    exit 1
fi

if [[ -z ${WORKING_DIR} ]]; then
    export WORKING_DIR='${PWD}/fcos'
fi

if [[ -z ${ASSEMBLE_SCRIPT} ]]; then
    export ASSEMBLE_SCRIPT="${DEFAULT_ASSEMBLE_SCRIPT}"
fi

# Make build dir
mkdir -p builds

# Copy assemble script to build node
echo "Copying assemble script to build node..."
gcloud compute scp "${DEFAULT_ASSEMBLE_SCRIPT}" proum-coreos-assembler:

# Start build script
echo "Starting assembler script..."
gcloud compute ssh proum-coreos-assembler -- "bash assemble.sh --config-repo ${CONFIG_REPO} --working-dir ${WORKING_DIR}"

# Copy final archive
gcloud compute scp proum-coreos-assembler:/tmp/proum-fedora-coreos.tar.xz builds/