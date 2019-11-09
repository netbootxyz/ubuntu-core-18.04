FROM ubuntu:bionic

# versioning
ARG EXTERNAL_VERSION

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"

# add local files
COPY /root /

RUN \
 echo "**** install deps ****" && \
 apt-get update && \
 apt-get install -y \
	casper \
	curl \
	initramfs-tools \
	p7zip-full \
	patch \
	pixz \
	psmisc \
	wget && \
 echo "**** patch casper ****" && \
 patch /usr/share/initramfs-tools/scripts/casper < /patch && \
 echo "**** install kernel ****" && \
 if [ -z ${EXTERNAL_VERSION+x} ]; then \
	EXTERNAL_VERSION=$(curl -sX GET http://archive.ubuntu.com/ubuntu/dists/bionic/main/binary-amd64/Packages.gz | gunzip -c |grep -A 7 -m 1 "Package: linux-image-virtual" | awk -F ": " '/Version/{print $2;exit}');\
 fi && \
 apt-get install -y \
	linux-image-virtual=${EXTERNAL_VERSION} && \
 echo "**** clean up ****" && \
 mkdir /buildout && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

ENTRYPOINT [ "/build.sh" ]
