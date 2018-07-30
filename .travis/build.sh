#!/bin/bash

set -Eeuo pipefail

docker_org="${1}"
tag="${2}"

for version in 8 10; do
	echo -e "#!/usr/bin/env bash\nset -Eeuo pipefail\nexec java \"\$@\"" > ${version}/entrypoint.sh
  for params in $(< ${version}/versions.txt); do
    arr_param=(${params//,/ })
    build_args=''
    for build_arg in ${arr_param[@]}; do
      build_args="${build_args} --build-arg ${build_arg}"
      eval "export ${build_arg}"
    done

    image_name=''
    if [ "x${tag}" = "xlatest" ]; then
      image_name="${docker_org}/java:${version}-${JAVA_PACKAGE}-${tag}"
    else
      image_name="${docker_org}/java:${JAVA_VERSION}-${JAVA_PACKAGE}-${tag}"
    fi
    docker build ${build_args} -t ${image_name} ${version}
  done
done