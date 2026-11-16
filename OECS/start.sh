
#!/bin/sh
set -eu

echo "Starting Tailscale..."

tailscaled \
  --tun=userspace-networking \
  --socks5-server=127.0.0.1:1055 \
  --socket=/tmp/tailscaled.sock \
  --state=mem: &

# Wait until Tailscale CLI can communicate with daemon
until tailscale --socket=/tmp/tailscaled.sock status >/dev/null 2>&1; do
  sleep 2
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
