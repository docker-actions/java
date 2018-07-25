FROM ubuntu:bionic as build

ARG JAVA_VERSION=10.0.2
ARG JAVA_VERSION_BUILD=13
ARG JAVA_PACKAGE=serverjre
ARG JAVA_SHA256_SUM=4ca492e0dd46c51bb3263d7347f6ede04fceb07fde3f01fed2c0336b18596c41
ARG JAVA_URL_ELEMENT=19aef61b38124481863b1413dce1855f

ENV ROOTFS /build/rootfs
ENV DEBIAN_FRONTEND=noninteractive

# Build pre-requisites
RUN bash -c 'mkdir -p ${ROOTFS}/{usr/local/bin,opt}'

# Install pre-requisites
RUN apt-get update \
      && apt-get -y install apt-utils curl unzip

# CA certs
RUN apt-get install -y ca-certificates ca-certificates-java \
      && update-ca-certificates \
      && cp -r /etc/ssl $ROOTFS/etc \
      && cp -r /usr/share/ca-certificates $ROOTFS/usr/share

# Java
RUN curl -jkLH "Cookie: oraclelicense=accept-securebackup-cookie" -o java.tar.gz\
    http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}+${JAVA_VERSION_BUILD}/${JAVA_URL_ELEMENT}/${JAVA_PACKAGE}-${JAVA_VERSION}_linux-x64_bin.tar.gz &&\
  echo "$JAVA_SHA256_SUM  java.tar.gz" | sha256sum -c - &&\
  gunzip -c java.tar.gz | tar -xf - -C $ROOTFS/opt && rm -f java.tar.gz &&\
  ln -s /opt/jdk-${JAVA_VERSION} $ROOTFS/opt/jdk

COPY entrypoint.sh ${ROOTFS}/usr/local/bin/entrypoint.sh
RUN chmod +x ${ROOTFS}/usr/local/bin/entrypoint.sh

FROM actions/bash:4.4.18-1
LABEL maintainer = "ilja+docker@bobkevic.com"

ARG ROOTFS=/build/rootfs

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV JAVA_HOME=/opt/jdk
ENV PATH=${PATH}:${JAVA_HOME}/bin

COPY --from=build ${ROOTFS} /

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]