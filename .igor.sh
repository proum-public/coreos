# This is igors config
# Original project: https://github.com/felixb/igor
# Install / update:
#   sudo curl https://raw.githubusercontent.com/felixb/igor/master/igor.sh -o /usr/local/bin/igor
#   sudo chmod +x /usr/local/bin/igor

CLOUDSDK_CONFIG=${PWD}/.gcloud
GOOGLE_APPLICATION_CREDENTIALS=${PWD}/.gcloud/application_default_credentials.json
HOME=${HOME}

IGOR_DOCKER_IMAGE=proum/terraform:v0.13.4-gcloud  # select docker image
IGOR_DOCKER_COMMAND=''     # run this command inside the docker conainer
IGOR_DOCKER_PULL=1         # force pulling the image before starting the container (0/1)
IGOR_DOCKER_RM=1           # remove container on exit (0/1)
IGOR_DOCKER_TTY=1          # open an interactive tty (0/1)
IGOR_DOCKER_USER=$(id -u)  # run commands inside the container with this user
IGOR_DOCKER_GROUP=$(id -g) # run commands inside the container with this group
IGOR_DOCKER_ARGS='--entrypoint=/bin/bash'        # default arguments to docker run
IGOR_PORTS=''              # space separated list of ports to expose
IGOR_MOUNT_PASSWD=1        # mount /etc/passwd inside the container (0/1)
IGOR_MOUNT_GROUP=1         # mount /etc/group inside the container (0/1)
IGOR_MOUNTS_RO=''          # space separated list of volumes to mount read only
IGOR_MOUNTS_RW=''          # space separated list of volumes to mount read write
IGOR_WORKDIR=${PWD}        # use this workdir inside the container
IGOR_WORKDIR_MODE=rw       # mount the workdir with this mode (ro/rw)
IGOR_ENV='CLOUDSDK_CONFIG GOOGLE_APPLICATION_CREDENTIALS HOME'                # space separated list of environment variables set inside the container
