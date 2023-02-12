FROM alpine:3.17.2 as builder

ARG OPENFORTIVPN_VERSION=v1.17.3
ARG GLIDER_VERSION=v0.16.2

RUN \
  apk add --no-cache \
    autoconf automake build-base ca-certificates curl git go openssl-dev ppp && \
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
  awk '/^\s+_/{if (!/http/ && !/socks5/ && !/mixed/) $0="//"$0} {print}' feature.go > feature.go.tmp && \
  mv feature.go.tmp feature.go && \
  go build -v -ldflags "-s -w"
COPY entrypoint.sh /usr/bin/

FROM alpine:3.17.2
RUN apk add --no-cache ca-certificates openssl ppp
COPY --from=builder /usr/bin/openfortivpn /go/src/github.com/nadoo/glider/glider /usr/bin/entrypoint.sh /usr/bin/
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
EXPOSE 8443/tcp
CMD ["openfortivpn"]
