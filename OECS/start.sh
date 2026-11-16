
#!/bin/sh
set -eu

# Start Tailscale without TUN
tailscaled \
  --tun=userspace-networking \
  --socks5-server=127.0.0.1:1055 \
  --state=mem: &

# Wait for Tailscale daemon
until tailscale status >/dev/null 2>&1; do
  sleep 2
done

# Authenticate Render with Tailscale
tailscale up \
  --auth-key="${TS_AUTHKEY:?Missing TS_AUTHKEY}" \
  --hostname=oecs-render

# Forward local JDBC traffic through Tailscale SOCKS5
socat \
  TCP-LISTEN:14330,bind=127.0.0.1,reuseaddr,fork \
  SOCKS5:127.0.0.1:100.91.247.7:1433,socksport=1055 &

# Configure Tomcat HTTP port
sed -i "s/port=\"8080\"/port=\"${PORT:-10000}\"/" \
  "$CATALINA_HOME/conf/server.xml"

exec catalina.sh run
