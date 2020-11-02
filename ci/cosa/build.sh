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
  echo ""
  echo "        -w --working-dir:       Path to cosa working directory"
  echo "                                (default: '\${PWD}/fcos') (ENV: WORKING_DIR)"
  echo ""
  echo "        -a --assemble-script:   Path to assemble script"
  echo "                                (default: ${DEFAULT_ASSEMBLE_SCRIPT}) (ENV: ASSEMBLE_SCRIPT)"
  echo ""
  echo "        -r --run-id:            ID of run (e.g. Github actions run id)"
  echo "                                (required) (ENV: RUN_ID)"
  echo ""
  echo "        -z --zone:              GCP zone"
  echo "                                (required) (ENV: GCP_ZONE)"
  echo ""
  echo "environment variables:"
  echo "        CONFIG_REPO:            URL to git repository with fedora coreos config (required)"
  echo "        WORKING_DIR:            Path to cosa config (default: '\${PWD}/fcos')"
  echo "        ASSEMBLE_SCRIPT:        Path to assemble script (default: ${DEFAULT_ASSEMBLE_SCRIPT})"
  echo "        RUN_ID:                 ID of run (e.g. Github actions run id) (required)"
  echo "        GCP_ZONE:               GCP zone (required)"
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
        --run-id|-r)
        export RUN_ID="$2"
        shift
        shift
        ;;
        --zone|-z)
        export GCP_ZONE="$2"
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

if [[ -z ${RUN_ID} ]]; then
    echo "RUN_ID not defined!"
    usage
    exit 1
fi

if [[ -z ${GCP_ZONE} ]]; then
    echo "GCP_ZONE not defined!"
    usage
    exit 1
fi

# Make build dir
mkdir -p builds

# Copy assemble script to build node
echo "Copying assemble script to build node..."
gcloud compute scp --zone "${GCP_ZONE}" "${DEFAULT_ASSEMBLE_SCRIPT}" "proum-coreos-assembler-run-${RUN_ID}:"

# Start build script
echo "Starting assembler script..."
gcloud compute ssh --zone "${GCP_ZONE}" "proum-coreos-assembler-run-${RUN_ID}:" -- "bash assemble.sh --config-repo ${CONFIG_REPO} --working-dir ${WORKING_DIR}"

# Copy final archive
gcloud compute scp --zone "${GCP_ZONE}" "proum-coreos-assembler-run-${RUN_ID}:/tmp/proum-fedora-coreos.tar.xz" builds/