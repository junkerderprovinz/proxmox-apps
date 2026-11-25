#!/usr/bin/env bash

# Copyright (c) 2026 junkerderprovinz
# Author: Junker der Provinz (junkerderprovinz)
# License: MIT | https://github.com/junkerderprovinz/proxmox-apps/raw/main/LICENSE
# Source: https://github.com/junkerderprovinz/knightloader

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
sed -i '/^Components:/{/non-free/!s/$/ non-free/}' /etc/apt/sources.list.d/debian.sources
$STD apt update
$STD apt install -y \
  ffmpeg \
  openjdk-21-jre-headless \
  chromium \
  fonts-noto-core \
  unrar
msg_ok "Installed Dependencies"

fetch_and_deploy_gh_release "yt-dlp" "yt-dlp/yt-dlp" "singlefile" "latest" "/opt/yt-dlp" "yt-dlp_linux"
fetch_and_deploy_gh_release "deno" "denoland/deno" "prebuild" "latest" "/opt/deno" "deno-x86_64-unknown-linux-gnu.zip"
fetch_and_deploy_gh_release "knightloader" "junkerderprovinz/knightloader" "tarball"
GO_VERSION="$(grep -m1 '^go ' /opt/knightloader/go.mod | awk '{print $2}')" setup_go

msg_info "Building KnightLoader"
cd /opt/knightloader
CGO_ENABLED=0 $STD go build -trimpath -ldflags "-s -w -X github.com/junkerderprovinz/knightloader/internal/buildinfo.Version=v$(cat ~/.knightloader)" -o /opt/knightloader/knightloader-server ./cmd/knightloader
$STD go clean -cache -modcache
mkdir -p /opt/knightloader/data
msg_ok "Built KnightLoader"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/knightloader.service
[Unit]
Description=KnightLoader
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/knightloader
Environment=KL_DATA=/opt/knightloader/data
Environment=KL_ADDR=:8749
Environment=KL_YTDLP=/opt/yt-dlp/yt-dlp
Environment=KL_DENO=/opt/deno/deno
Environment=KL_CHROMIUM=/usr/bin/chromium
Environment=KL_UNRAR=/usr/bin/unrar
ExecStart=/opt/knightloader/knightloader-server
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now knightloader
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
