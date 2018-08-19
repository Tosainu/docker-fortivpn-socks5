FROM golang:1.10-alpine3.8 as builder

ENV OPENFORTIVPN_VERSION=v1.7.1

RUN \
  apk update && \
  apk add --no-cache \
    autoconf automake build-base ca-certificates curl git openssl-dev ppp && \
  update-ca-certificates && \
  # build openfortivpn
  mkdir -p /usr/src/openfortivpn && \
  curl -sL https://github.com/adrienverge/openfortivpn/archive/${OPENFORTIVPN_VERSION}.tar.gz \
    | tar xz -C /usr/src/openfortivpn --strip-components=1 && \
  cd /usr/src/openfortivpn && \
  ./autogen.sh && \
  ./configure --prefix=/usr --sysconfdir=/etc && \
  make -j$(nproc) && \
  make install && \
  # build glider
  go get -u github.com/nadoo/glider

FROM alpine:3.8

RUN \
  apk update && \
  apk add --no-cache \
    bash ca-certificates openssl ppp

COPY --from=builder /usr/bin/openfortivpn /go/bin/glider /usr/bin/
