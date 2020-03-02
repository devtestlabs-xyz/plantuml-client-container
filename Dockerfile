# Official Python image
FROM python:3.8.1-alpine3.11

COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

# Required packages
ENV APK_PACKAGES \
  ca-certificates \
  su-exec \
  # https://stackoverflow.com/questions/41807026/cant-add-a-user-with-a-high-uid-in-docker-alpine/53604334#53604334
  shadow \
  bash

ENV PIP_PACKAGES \
  plantweb

RUN set -x \
 && env \
 && echo "==> Upgrading apk and system. .."  \
 && apk update && apk upgrade \
 && echo "==> Installing required packages ..."  \
 && apk add --no-cache ${APK_PACKAGES} \
 && pip install --no-cache-dir ${PIP_PACKAGES} \
 && echo "===> Creating symlinks for entrypoint.sh..." \
 && ln -s /usr/local/bin/entrypoint.sh / \
 && echo "===> chmod entrypoint.sh ..." \
 && chmod +x /usr/local/bin/entrypoint.sh \
 && echo "===> Cleaning up ..."  \
 && unset http_proxy https_proxy

WORKDIR /images
VOLUME [ "/puml" ]
VOLUME [ "/images" ]

ENTRYPOINT [ "/entrypoint.sh" ]