FROM curlimages/curl:8.15.0 AS builder
ARG TARGETPLATFORM
ARG UPSTREAM_VERSION=v0.8.5
RUN DOCKER_ARCH=$(case ${TARGETPLATFORM:-linux/amd64} in \
  "linux/amd64")   echo "amd64"  ;; \
  "linux/arm/v7")  echo "arm64"   ;; \
  "linux/arm64")   echo "arm64" ;; \
  *)               echo ""        ;; esac) \
  && echo "DOCKER_ARCH=$DOCKER_ARCH" \
  && curl --fail -L https://github.com/mautrix/signal/releases/download/${UPSTREAM_VERSION}/mautrix-signal-${DOCKER_ARCH} > /tmp/mautrix-signal
RUN chmod 0755 /tmp/mautrix-signal
# just test the download
RUN /tmp/mautrix-signal --help

FROM debian:12.11-slim AS runtime
RUN apt-get update && apt-get install -y \
  ca-certificates=20230311 \
  gettext-base=0.21-12 \
  && rm -rf /var/lib/apt/lists/*
COPY --from=builder /tmp/mautrix-signal /usr/bin/mautrix-signal
USER 1337
ENTRYPOINT ["/usr/bin/mautrix-signal"]
