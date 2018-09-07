#!/bin/bash

set -Eeuo pipefail

docker_org="${1}"
tag="${2}"

image_name=''
if [ "x${tag}" = "xlatest" ]; then
  image_name="${docker_org}/java:${BUILD_PATH}-${JAVA_PACKAGE}-${tag}"
else
  image_name="${docker_org}/java:${JAVA_VERSION}-${JAVA_PACKAGE}-${tag}"
fi
docker push ${image_name}