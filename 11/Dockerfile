ARG ROOTFS=/build/rootfs

FROM ubuntu:bionic as build

ARG JAVA_VERSION=11.0.1
ARG JAVA_VERSION_BUILD=13
ARG JAVA_PACKAGE=jdk
ARG JAVA_SHA256_SUM=e7fd856bacad04b6dbf3606094b6a81fa9930d6dbb044bbd787be7ea93abc885
ARG JAVA_URL_ELEMENT=90cf5d8f270a4347a95050320eef3fb7
ARG ROOTFS

ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE true

RUN : "${JAVA_VERSION:?Build argument needs to be set and non-empty.}"
RUN : "${JAVA_VERSION_BUILD:?Build argument needs to be set and non-empty.}"
RUN : "${JAVA_PACKAGE:?Build argument needs to be set and non-empty.}"
RUN : "${JAVA_SHA256_SUM:?Build argument needs to be set and non-empty.}"
RUN : "${JAVA_URL_ELEMENT:?Build argument needs to be set and non-empty.}"
RUN : "${ROOTFS:?Build argument needs to be set and non-empty.}"

SHELL ["bash", "-Eeuc"]

# Build pre-requisites
RUN mkdir -p ${ROOTFS}/{sbin,usr/bin,usr/local/bin,opt}

# Install pre-requisites
RUN set -Eeuo pipefail; \
    apt-get update; \
    apt-get -y install apt-utils curl unzip

# CA certs
RUN set -Eeuo pipefail; \
    apt-get install -y ca-certificates ca-certificates-java; \
    update-ca-certificates; \
    cp -r /etc/ssl $ROOTFS/etc; \
    cp -r /usr/share/ca-certificates $ROOTFS/usr/share

# Java
RUN set -Eeuo pipefail; \
    curl -jkLH "Cookie: oraclelicense=accept-securebackup-cookie" -o java.tar.gz \
      http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}+${JAVA_VERSION_BUILD}/${JAVA_URL_ELEMENT}/${JAVA_PACKAGE}-${JAVA_VERSION}_linux-x64_bin.tar.gz; \
    echo "$JAVA_SHA256_SUM java.tar.gz" | sha256sum -c - ; \
    gunzip -c java.tar.gz | tar -xf - -C $ROOTFS/opt; \
    rm -f java.tar.gz; \
    cd ${ROOTFS}/opt/$(basename ${ROOTFS}/opt/jdk*)/bin; \
    for jdkbin in *; do \
      ln -s /opt/jdk/bin/$jdkbin ${ROOTFS}/usr/bin/$jdkbin; \
    done; \
    ln -s /opt/$(basename ${ROOTFS}/opt/jdk*) ${ROOTFS}/opt/jdk

# Move /sbin out of the way
RUN set -Eeuo pipefail; \
    mv ${ROOTFS}/sbin ${ROOTFS}/sbin.orig; \
    mkdir -p ${ROOTFS}/sbin; \
    for b in ${ROOTFS}/sbin.orig/*; do \
      echo 'cmd=$(basename ${BASH_SOURCE[0]}); exec /sbin.orig/$cmd "$@"' > ${ROOTFS}/sbin/$(basename $b); \
      chmod +x ${ROOTFS}/sbin/$(basename $b); \
    done

COPY entrypoint.sh ${ROOTFS}/usr/local/bin/entrypoint.sh
RUN chmod +x ${ROOTFS}/usr/local/bin/entrypoint.sh

FROM actions/bash:4.4.18-8
LABEL maintainer = "ilja+docker@bobkevic.com"

ARG ROOTFS

RUN : "${ROOTFS:?Build argument needs to be set and non-empty.}"

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV JAVA_HOME=/opt/jdk

COPY --from=build ${ROOTFS} /

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]