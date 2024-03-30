FROM nginx:1.25.4-alpine3.18

WORKDIR /app

RUN mkdir -p /app/apis \
  && apk add --no-cache \
    jq \
    bash \
    sqlite \
    tzdata \
    fcgiwrap
