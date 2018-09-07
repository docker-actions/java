#!/bin/bash

set -Eeuo pipefail

docker_org="${1}"
tag="${2}"

echo -e "#!/usr/bin/env bash\nset -Eeuo pipefail\nexec java \"\$@\"" > ${BUILD_PATH}/entrypoint.sh
build_args=''
for ba in $BUILD_ARGS; do
  build_args="${build_args} --build-arg ${ba}=${!ba}"
done

image_name=''
if [ "x${tag}" = "xlatest" ]; then
  image_name="${docker_org}/java:${BUILD_PATH}-${JAVA_PACKAGE}-${tag}"
else
  image_name="${docker_org}/java:${JAVA_VERSION}-${JAVA_PACKAGE}-${tag}"
fi
docker build ${build_args} -t ${image_name} ${BUILD_PATH}