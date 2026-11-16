
#!/bin/sh
set -eu

echo "Starting Tailscale..."

tailscaled \
  --tun=userspace-networking \
  --socks5-server=127.0.0.1:1055 \
  --socket=/tmp/tailscaled.sock \
  --state=mem: &

echo "Waiting for Tailscale socket..."

# Wait for the socket, not login status
i=0
while [ ! -S /tmp/tailscaled.sock ]; do
  i=$((i + 1))
  if [ "$i" -ge 30 ]; then
    echo "ERROR: Tailscale socket not created"
    exit 1
  fi
  sleep 1
done

echo "Authenticating Tailscale..."

tailscale --socket=/tmp/tailscaled.sock up \
  --auth-key="${TS_AUTHKEY:?Missing TS_AUTHKEY}" \
  --hostname=oecs-render

echo "Starting SQL Server proxy..."

socat \
  TCP-LISTEN:14330,bind=127.0.0.1,reuseaddr,fork \
  SOCKS5:127.0.0.1:100.91.247.7:1433,socksport=1055 &

echo "Starting Tomcat..."

sed -i "s/port=\"8080\"/port=\"${PORT:-10000}\"/" \
  "$CATALINA_HOME/conf/server.xml"

exec catalina.sh run
