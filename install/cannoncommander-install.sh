#!/usr/bin/env bash

# Copyright (c) 2026 junkerderprovinz
# Author: Junker der Provinz (junkerderprovinz)
# License: MIT | https://github.com/junkerderprovinz/proxmox-apps/raw/main/LICENSE
# Source: https://github.com/junkerderprovinz/cannoncommander

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y \
  build-essential \
  ffmpeg \
  rclone \
  fuse3 \
  7zip \
  mupdf-tools \
  media-types
msg_ok "Installed Dependencies"

NODE_VERSION="24" setup_nodejs

fetch_and_deploy_gh_release "cannoncommander" "junkerderprovinz/cannoncommander" "tarball"
GO_VERSION="$(grep -m1 '^go ' /opt/cannoncommander/backend/go.mod | awk '{print $2}')" setup_go

msg_info "Building CannonCommander"
cd /opt/cannoncommander/frontend
$STD npm ci --no-audit --no-fund
$STD npm run build:docker
mkdir -p /opt/cannoncommander/backend/internal/web
cp -r /opt/cannoncommander/frontend/dist /opt/cannoncommander/backend/internal/web/dist
cd /opt/cannoncommander/backend
$STD go run ./scripts/setup-gofitz-cgo
CGO_ENABLED=1 $STD go build -tags mupdf -ldflags "-w -s -X 'github.com/junkerderprovinz/cannoncommander/backend/internal/version.Version=v$(cat ~/.cannoncommander)'" -o /opt/cannoncommander/backend/cannoncommander .
$STD go clean -cache -modcache
rm -rf /opt/cannoncommander/frontend/node_modules ~/.npm
mkdir -p /opt/cannoncommander/config /remotes
cp /opt/cannoncommander/_docker/config.yaml /opt/cannoncommander/config/config.yaml
msg_ok "Built CannonCommander"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/cannoncommander.service
[Unit]
Description=CannonCommander
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/cannoncommander/backend
Environment=CC_CONFIG=/opt/cannoncommander/config/config.yaml
Environment=CC_DATABASE_PATH=/opt/cannoncommander/config/cannoncommander.sqlite
Environment=CC_FFMPEG_PATH=/usr/bin/
ExecStart=/opt/cannoncommander/backend/cannoncommander
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now cannoncommander
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
