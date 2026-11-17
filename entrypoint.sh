#!/bin/sh
set -e

cat > /etc/shadowsocks-libev/config.json <<EOF
{
  "server":"0.0.0.0",
  "server_port":2333,
  "password":"${Password}",
  "timeout":300,
  "method":"chacha20-ietf-poly1305",
  "mode":"tcp_only",
  "fast_open":false,
  "reuse_port":true,
  "no_delay":true,
  "plugin":"v2",
  "plugin_opts":"server;path=/v2",
  "remarks":"Aditya's VPN"
}
EOF

mkdir -p /etc/nginx/conf.d
cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen ${PORT};
    server_name _;
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
    location /v2 {
        proxy_pass http://127.0.0.1:2333;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}
EOF

ss-server -c /etc/shadowsocks-libev/config.json &
exec nginx -g 'daemon off;'
