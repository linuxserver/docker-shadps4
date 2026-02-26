# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE="shadPS4" \
    PIXELFLUX_WAYLAND=true

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/shadps4-logo.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    unzip && \
  echo "**** install shadps4qt ****" && \
  if [ -z ${SHADPS4_VERSION+x} ]; then \
    SHADPS4_VERSION=$(curl -sX GET "https://api.github.com/repos/shadps4-emu/shadps4-qtlauncher/releases" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  SHORT_VERSION=$(echo "$SHADPS4_VERSION" | sed 's/shadPS4QtLauncher-//' | cut -c 1-18) && \
  curl -o \
    /tmp/shad.zip -L \
    "https://github.com/shadps4-emu/shadps4-qtlauncher/releases/download/${SHADPS4_VERSION}/shadPS4QtLauncher-linux-qt-${SHORT_VERSION}.zip" && \
  cd /tmp && \
  unzip shad.zip && \
  chmod +x shadPS4QtLauncher-qt.AppImage && \
  ./shadPS4QtLauncher-qt.AppImage --appimage-extract && \
  mv \
    squashfs-root \
    /opt/shadps4 && \
  echo "**** cleanup ****" && \
  printf \
    "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" \
    > /build_version && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3001

VOLUME /config
