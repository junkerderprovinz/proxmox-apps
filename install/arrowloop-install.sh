#!/usr/bin/env bash

# Copyright (c) 2026 junkerderprovinz
# Author: Junker der Provinz (junkerderprovinz)
# License: MIT | https://github.com/junkerderprovinz/proxmox-apps/raw/main/LICENSE
# Source: https://github.com/junkerderprovinz/arrowloop

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

NODE_VERSION="24" setup_nodejs

fetch_and_deploy_gh_release "arrowloop" "junkerderprovinz/arrowloop" "tarball"
GO_VERSION="$(grep -m1 '^go ' /opt/arrowloop/go.mod | awk '{print $2}')" setup_go

msg_info "Building ArrowLoop"
cd /opt/arrowloop
$STD npm --prefix web ci --no-audit --no-fund
$STD npm --prefix web run build
CGO_ENABLED=0 $STD go build -trimpath -ldflags "-s -w -X github.com/junkerderprovinz/arrowloop/internal/boot.Version=v$(cat ~/.arrowloop)" -o /opt/arrowloop/arrowloop ./cmd/arrowloop
$STD go clean -cache -modcache
rm -rf /opt/arrowloop/web/node_modules ~/.npm
mkdir -p /opt/arrowloop/config
msg_ok "Built ArrowLoop"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/arrowloop.service
[Unit]
Description=ArrowLoop
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/arrowloop
Environment=ARROWLOOP_ADDR=0.0.0.0:8422
ExecStart=/opt/arrowloop/arrowloop web -config /opt/arrowloop/config/arrowloop.json
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now arrowloop
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
