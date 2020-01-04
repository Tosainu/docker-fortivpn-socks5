FROM golang:1.13-alpine3.11 as builder

ARG OPENFORTIVPN_VERSION=v1.11.0
ARG GLIDER_VERSION=v0.9.2

RUN \
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
COPY entrypoint.sh /usr/bin/

FROM alpine:3.11
RUN apk add --no-cache ca-certificates openssl ppp
COPY --from=builder /usr/bin/openfortivpn /go/bin/glider /usr/bin/entrypoint.sh /usr/bin/
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["openfortivpn"]
