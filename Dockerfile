FROM golang:latest AS builder

WORKDIR /app

RUN git clone --depth 1 https://github.com/tailscale/tailscale/ && \
    cd tailscale/cmd/derper && \
    CGO_ENABLED=0 /usr/local/go/bin/go build -buildvcs=false -ldflags "-s -w" -o /app/derper

FROM ubuntu:22.04

LABEL org.opencontainers.image.source https://github.com/flxxyz/derper
LABEL maintainer="shinji@sao.sh"

USER derper

ARG VERBOSE=1
ARG DERP_PORT=33333
ARG DERP_CONN_LIMIT=100
ARG DERP_VERIFY_CLENTS=1
ARG DERP_CONF=/opt/derper/derper.conf
ARG CERT_DIR=/opt/derper/cert

ENV DERP_HOST=
ENV VERBOSE=${VERBOSE}
ENV DERP_PORT=${DERP_PORT}
ENV DERP_CONN_LIMIT=${DERP_CONN_LIMIT}
ENV DERP_VERIFY_CLENTS=${DERP_VERIFY_CLENTS}
ENV DERP_CONF=${DERP_CONF}
ENV CERT_DIR=${CERT_DIR}

WORKDIR /opt/derper

COPY --chown=derper:derper . .
COPY --from=builder /app/derper bin/derper

EXPOSE ${DERP_PORT}/udp
EXPOSE ${DERP_PORT}/tcp

ENTRYPOINT /opt/derper/derper.sh \
  --host $DERP_HOST \
  --port $DERP_PORT \
  --limit $DERP_CONN_LIMIT \
  --conf $DERP_CONF \
  --cert $CERT_DIR \
  --verbose \
  --start
