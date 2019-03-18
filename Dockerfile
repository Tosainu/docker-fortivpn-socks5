FROM golang:1.12-alpine3.9 as builder

ARG OPENFORTIVPN_VERSION=v1.9.0
ARG GLIDER_VERSION=v0.6.11

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
  mkdir -p /go/src/github.com/nadoo/glider && \
  curl -sL https://github.com/nadoo/glider/archive/${GLIDER_VERSION}.tar.gz \
    | tar xz -C /go/src/github.com/nadoo/glider --strip-components=1 && \
  cd /go/src/github.com/nadoo/glider && \
  go get -v ./...

FROM alpine:3.9

RUN \
  apk update && \
  apk add --no-cache \
    bash ca-certificates openssl ppp

COPY --from=builder /usr/bin/openfortivpn /go/bin/glider /usr/bin/
COPY entrypoint.sh /usr/bin/

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["openfortivpn"]
