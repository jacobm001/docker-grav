FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.14

ARG BUILD_DATE
ARG VERSION
ARG GRAV_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="TheSpad"

RUN \
  apk add --update --no-cache \
    curl \
    composer \
    php7-dom \
    php7-gd \
    php7-tokenizer \
    php7-opcache \
    php7-pecl-apcu \
    php7-pecl-yaml \
    php7-intl \
    php7-redis \
    busybox-suid \
    unzip && \
  { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.enable_cli=1'; \
  } > /etc/php7/conf.d/php-opcache.ini && \
  if [ -z ${GRAV_RELEASE+x} ]; then \
    GRAV_RELEASE=$(curl -sX GET "https://api.github.com/repos/getgrav/grav/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  echo "*** Installing Grav ***" && \
  curl -o \
    /tmp/grav.zip -L \
    "https://github.com/getgrav/grav/releases/download/${GRAV_RELEASE}/grav-admin-v${GRAV_RELEASE}.zip" && \
  unzip -q \
    /tmp/grav.zip -d /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf \
    /tmp/*

COPY root/ /

EXPOSE 80

VOLUME /config
