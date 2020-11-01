# DockerHub Description Uploader

> A simple ```alpine``` based container for pushing README.md files to
hub.docker.com in Gitlab CI pipelines

## Quick reference

* Sourcecode:
  [click here](https://gitlab.com/proum-public/dockerhub-description)
* Maintainer: [@hmettendorf](https://gitlab.com/hmettendorf)

## Getting Started

These instructions will cover usage information and for the docker container

### Prerequisities

In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

### Usage

#### Container Parameters

You can start the uploader container either with command line arguments
or the environment variables.

For example via command line arguments:

```shell script
docker run \
-v $(pwd):/usr/local/src \
proum/dockerhub-description \
--dockerhub-username john.doe \
--dockerhub-password secret \
--dockerhub-repository johndoe/example \
--description-file /usr/local/src/README.md
```

or via environment variables:

```shell script
docker run \
-v $(pwd):/usr/local/src \
-e DOCKERHUB_USERNAME=john.doe \
-e DOCKERHUB_PASSWORD=secret \
-e DOCKERHUB_REPOSITORY=johndoe/example \
-e DESCRIPTION_FILE=/usr/local/src/README.md \
proum/dockerhub-description
```

or in a Gitlab CI pipeline (in case you want to upload the `README.md`:

```yaml
image: docker:stable

stages:
  - post-release

services:
  - docker:dind

variables:
  DOCKERHUB_REPOSITORY: johndoe/example
  DOCKERHUB_USER: john.doe
  DOCKERHUB_PASSWORD: secret

before_script:
  - docker login -u ${DOCKERHUB_USER} -p ${DOCKERHUB_PASSWORD}

upload-description:
  image: proum/dockerhub-description
  stage: post-release
  script:
    - "--pipeline"
  only:
    - master
```

**Hint**: Gitlab CI needs a `script`-section and therefor we
need to provide something...

#### Configuration

* **`DOCKERHUB_USERNAME`** or (`-u | --dockerhub-username`) (**required**)

    Username of the hub.docker.com login

* **`DOCKERHUB_PASSWORD`** or (`-p | --dockerhub-password`) (**required**)

    Password of the hub.docker.com login

* **`DOCKERHUB_REPOSITORY`** or (`-r | --dockerhub-repository`) (**required**)

    URL of the hub.docker.com repository to which the file will be uploaded

* **`DESCRIPTION_FILE`** or (`-f | --description-file`) (*default:* README.md)

    Path to the file which will be uploaded

#### Volumes

* none

## CVE Scan Report

The subject of the scan is always the image with the `latest` tag.
Older releases/tags may contain unknown vulnerabilities!
The list only contains CVE that have already been fixed,
but not yet included in this image due to outdated package sources.

If you wish to get a complete list, please run:

```
docker run -it --rm aquasec/trivy \
    proum/<image>:<tag>
```

@[:markdown](cve_report.md)

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available,
see the [tags on this repository](https://github.com/your/repository/tags).

## License

This project is licensed under the GNU v2 License -
see the [LICENSE.md](LICENSE.md) file for details.