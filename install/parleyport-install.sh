#!/usr/bin/env bash

# Copyright (c) 2026 junkerderprovinz
# Author: Junker der Provinz (junkerderprovinz)
# License: MIT | https://github.com/junkerderprovinz/proxmox-apps/raw/main/LICENSE
# Source: https://github.com/junkerderprovinz/parleyport

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

fetch_and_deploy_gh_release "parleyport" "junkerderprovinz/parleyport" "tarball"
GO_VERSION="$(grep -m1 '^go ' /opt/parleyport/go.mod | awk '{print $2}')" setup_go

msg_info "Building ParleyPort"
cd /opt/parleyport
CGO_ENABLED=0 $STD go build -ldflags "-s -w -X github.com/junkerderprovinz/parleyport/internal/buildinfo.Version=v$(cat ~/.parleyport)" -o /opt/parleyport/parleyport ./cmd/parleyport
$STD go clean -cache -modcache
mkdir -p /var/lib/parleyport/certs
msg_ok "Built ParleyPort"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/parleyport.service
[Unit]
Description=ParleyPort
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/var/lib/parleyport
EnvironmentFile=-/var/lib/parleyport/parleyport.env
ExecStart=/opt/parleyport/parleyport
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now parleyport
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
