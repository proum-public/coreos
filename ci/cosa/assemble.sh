#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"

DEFAULT_COSA_WORKING_DIR="${PWD}/fcos"

cosa() {
   podman run --rm -ti --security-opt label=disable --privileged                                    \
              --uidmap=1000:0:1 --uidmap=0:1:1000 --uidmap 1001:1001:64536                          \
              -v ${PWD}:/srv/ --device /dev/kvm --device /dev/fuse                                  \
              --tmpfs /tmp -v /var/tmp:/var/tmp --name cosa                                         \
              ${COREOS_ASSEMBLER_CONFIG_GIT:+-v $COREOS_ASSEMBLER_CONFIG_GIT:/srv/src/config/:ro}   \
              ${COREOS_ASSEMBLER_GIT:+-v $COREOS_ASSEMBLER_GIT/src/:/usr/lib/coreos-assembler/:ro}  \
              ${COREOS_ASSEMBLER_CONTAINER_RUNTIME_ARGS}                                            \
              ${COREOS_ASSEMBLER_CONTAINER:-quay.io/coreos-assembler/coreos-assembler:latest} "$@"
   rc=$?; set +x; return $rc
}

# check prerequisites
for cmd in cosa
do
    command -v ${cmd} > /dev/null || {  echo >&2 "${cmd} must be installed - exiting..."; exit 1; }
done

function usage() {
  echo "usage: $0"
  echo ""
  echo "        -c --config-repo:       URL to git repository with fedora coreos config"
  echo "                                (required) (ENV: CONFIG_REPO)"
  echo "        -w --working-dir:       Path to cosa working directory"
  echo "                                (default: ${DEFAULT_COSA_WORKING_DIR}) (ENV: WORKING_DIR)"
  echo ""
  echo "environment variables:"
  echo "        CONFIG_REPO:            URL to git repository with fedora coreos config (required)"
  echo "        WORKING_DIR:            Path to cosa config (default: ${DEFAULT_COSA_WORKING_DIR})"
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
    export WORKING_DIR="${DEFAULT_COSA_WORKING_DIR}"
fi

# Setup working dir
echo "Setup working directory '${WORKING_DIR}'..."
sudo mkdir -p ${WORKING_DIR} \
  && sudo chown -R $(id -u -n):$(id -g -n) ${WORKING_DIR} \
  && cd ${WORKING_DIR}

# Load Fedora CoreOS config
echo "Fetching configuration from '${CONFIG_REPO}'..."
cosa init --force "${CONFIG_REPO}"

# Fetch metadata and packages
echo "Fetching metadata and packages..."
cosa fetch

# Build image
echo "Building metal image..."
cosa build metal

# Compress build
echo "Compressing build..."
for build in $(find builds/ -name "*.x86_64.tar"); do
  echo "Build: ${build}"
  xz -e -T 0 -v -z ${build}

  # Copy final archive
  mv "${build}.xz" /tmp/proum-fedora-coreos.tar.xz
done