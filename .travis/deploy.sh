#!/bin/bash

set -Eeuo pipefail

docker_org="${1}"
tag="${2}"

for version in 8 10; do
  for params in $(< ${version}/versions.txt); do
    arr_param=(${params//,/ })
    for build_arg in ${arr_param[@]}; do
      eval "export ${build_arg}"
    done

    image_name=''
    if [ "x${tag}" = "xlatest" ]; then
      image_name="${docker_org}/java:${version}-${JAVA_PACKAGE}-${tag}"
    else
      image_name="${docker_org}/java:${JAVA_VERSION}-${JAVA_PACKAGE}-${tag}"
    fi
    docker push ${image_name}
  done
done