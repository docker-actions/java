FROM ubuntu:bionic as build

ARG JAVA_VERSION=8u181
ARG JAVA_VERSION_BUILD=b13
ARG JAVA_PACKAGE=jdk
ARG JAVA_SHA256_SUM=1845567095bfbfebd42ed0d09397939796d05456290fb20a83c476ba09f991d3
ARG JAVA_URL_ELEMENT=96a7b8442fe848ef90c96a2fad6ed6d1

ENV ROOTFS /build/rootfs
ENV DEBIAN_FRONTEND=noninteractive

# Build pre-requisites
RUN bash -c 'mkdir -p ${ROOTFS}/{sbin,usr/bin,usr/local/bin,opt}'

# Install pre-requisites
RUN apt-get update \
      && apt-get -y install apt-utils curl unzip

# CA certs
RUN apt-get install -y ca-certificates ca-certificates-java \
      && update-ca-certificates \
      && cp -r /etc/ssl $ROOTFS/etc \
      && cp -r /usr/share/ca-certificates $ROOTFS/usr/share

# Java
RUN curl -jkLH "Cookie: oraclelicense=accept-securebackup-cookie" -o java.tar.gz \
      http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}-${JAVA_VERSION_BUILD}/${JAVA_URL_ELEMENT}/${JAVA_PACKAGE}-${JAVA_VERSION}-linux-x64.tar.gz \
    && echo "$JAVA_SHA256_SUM  java.tar.gz" | sha256sum -c - \
    && gunzip -c java.tar.gz | tar -xf - -C $ROOTFS/opt \
    && rm -f java.tar.gz \
    && cd ${ROOTFS}/opt/$(basename ${ROOTFS}/opt/jdk*)/bin \
    && for jdkbin in *; do \
         ln -s /opt/jdk/bin/$jdkbin ${ROOTFS}/usr/bin/$jdkbin; \
       done \
    && ln -s /opt/$(basename ${ROOTFS}/opt/jdk*) ${ROOTFS}/opt/jdk

# Move /sbin out of the way
RUN mv ${ROOTFS}/sbin ${ROOTFS}/sbin.orig \
      && mkdir -p ${ROOTFS}/sbin \
      && for b in ${ROOTFS}/sbin.orig/*; do \
           echo 'cmd=$(basename ${BASH_SOURCE[0]}); exec /sbin.orig/$cmd "$@"' > ${ROOTFS}/sbin/$(basename $b); \
           chmod +x ${ROOTFS}/sbin/$(basename $b); \
         done

COPY entrypoint.sh ${ROOTFS}/usr/local/bin/entrypoint.sh
RUN chmod +x ${ROOTFS}/usr/local/bin/entrypoint.sh

FROM actions/bash:4.4.18-6
LABEL maintainer = "ilja+docker@bobkevic.com"

ARG ROOTFS=/build/rootfs

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV JAVA_HOME=/opt/jdk

COPY --from=build ${ROOTFS} /

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]