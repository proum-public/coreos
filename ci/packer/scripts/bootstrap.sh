#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"

# check prerequisites
for cmd in apt
do
    command -v ${cmd} > /dev/null || {  echo >&2 "${cmd} must be installed - exiting..."; exit 1; }
done

function usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Bootstrap docker runtime"
  echo ""
  echo "        -d --docker-version       Version of docker daemon (ENV: 'DOCKER_VERSION')"
  echo ""
  echo "Environment variables:"
  echo ""
  echo "        DOCKER_VERSION           Version of docker daemon"
}

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --docker-version|-d)
        export DOCKER_VERSION="$2"
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

if [[ -z ${DOCKER_VERSION} ]]; then
    export DOCKER_VERSION="18.03"
fi

# Clean up
apt-get remove \
  docker \
  docker-engine docker.io containerd runc

apt update \
  && apt install

exit 0