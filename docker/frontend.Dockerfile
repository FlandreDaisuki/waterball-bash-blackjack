FROM alpine:3.18

WORKDIR /app

RUN mkdir -p /app \
  && apk add --no-cache \
    jq \
    bash \
    curl \
    tzdata
