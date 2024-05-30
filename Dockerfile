FROM curlimages/curl:8.8.0 AS builder
ARG SIGNAL_VERSION
ENV SIGNAL_VERSION=${SIGNAL_VERSION}
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && curl -sL https://github.com/mautrix/signal/releases/download/v${SIGNAL_VERSION}/mautrix-signal-${arch} > /tmp/mautrix-signal
RUN chmod 0755 /tmp/mautrix-signal

FROM debian:12.5-slim AS runtime
RUN apt-get update && apt-get install -y \
    ca-certificates=20230311 \
 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /tmp/mautrix-signal /usr/bin/mautrix-signal
ENTRYPOINT ["/usr/bin/mautrix-signal"]
