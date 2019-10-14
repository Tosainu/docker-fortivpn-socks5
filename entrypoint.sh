#!/bin/sh
/usr/bin/glider -listen :8443 &
echo "http/socks5 proxy server: $(hostname -i):8443"
exec "$@"
