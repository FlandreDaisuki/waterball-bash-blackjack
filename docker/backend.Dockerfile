FROM nginx:1.25.4-alpine3.18

WORKDIR /app

# https://stackoverflow.com/a/55757473
ENV USER=user
ENV GROUPNAME="$USER"
ENV UID=1000
ENV GID=1000

RUN addgroup \
    --gid "$GID" \
    "$GROUPNAME" \
  && adduser \
    --disabled-password \
    --ingroup "$GROUPNAME" \
    --no-create-home \
    --uid "$UID" \
    "$USER" \
  && addgroup nginx user \
  && apk add --no-cache \
    jq \
    bash \
    sqlite \
    tzdata \
    fcgiwrap \
  && mkdir -p /app/apis \
  && chown -R user:user /app
