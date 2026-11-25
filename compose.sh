#!/usr/bin/env bash
# Runs one of junkerderprovinz's apps with Docker in its own Proxmox container,
# from the compose file in the app's repository.
#
#   compose.sh install <app>    create a Debian container with Docker and start the app in it
#   compose.sh update <app>     pull the app's images again and update Docker in the container
#   compose.sh list             show the apps this script knows
#
# Settings come from the environment: CTID, STORAGE (default local-lvm),
# TEMPLATE_STORAGE (default local), BRIDGE (default vmbr0), NET (default
# ip=dhcp, for example "ip=192.168.1.50/24,gw=192.168.1.1"), CORES, MEMORY,
# DISK. A value the compose file marks as required is passed the same way,
# under its name in the file.
set -euo pipefail

GH=https://raw.githubusercontent.com/junkerderprovinz

app_catalog() {
  case "$1" in
  bombvault)
    url=$GH/bombvault/main/deploy/docker-compose.generic.yml port=3443 scheme=https memory=2048 disk=16
    required=("APP_KEY") ;;
  openhands)
    url=$GH/unraid-apps/main/openhands/compose.yaml port=3000 memory=4096 disk=32
    defaults=("SANDBOX_VOLUMES=/opt/openhands/workspace:/workspace:rw") ;;
  *) return 1 ;;
  esac
}

APPS="bombvault openhands"

die() { echo "error: $*" >&2; exit 1; }
say() { echo "-> $*"; }

load() {
  app=$1 url="" port="" scheme=http memory=2048 disk=16
  required=() defaults=()
  app_catalog "$app" || die "unknown app '$app', see: compose.sh list"
  memory=${MEMORY:-$memory}
  disk=${DISK:-$disk}
}

find_ct() {
  local id
  for id in $(pct list | awk 'NR > 1 {print $1}'); do
    if grep -q "^hostname: $app$" "/etc/pve/lxc/$id.conf" && grep -q "^tags:.*compose-app" "/etc/pve/lxc/$id.conf"; then
      echo "$id"
      return 0
    fi
  done
  return 1
}

template() {
  local storage=${TEMPLATE_STORAGE:-local} name
  pveam update >/dev/null
  name=$(pveam available --section system | awk '{print $2}' | grep "^debian-13-standard_.*_$(dpkg --print-architecture)\." | sort -V | tail -1)
  [ -n "$name" ] || die "no Debian 13 template in the catalogue"
  pveam list "$storage" | grep -q "$name" || pveam download "$storage" "$name" >/dev/null
  echo "$storage:vztmpl/$name"
}

# The compose file says which values it needs: an empty or placeholder value
# marked "# required". Each one set in the environment, or as a default here,
# replaces the value on its line.
fill_compose() {
  local file=$1 kv key value missing=()
  for kv in "${defaults[@]}"; do
    key=${kv%%=*}
    [ -n "${!key:-}" ] || printf -v "$key" '%s' "${kv#*=}"
    export "${key?}"
  done
  for key in $(grep -E '^\s+[A-Z0-9_]+:.*# required' "$file" | sed -E 's/^\s+([A-Z0-9_]+):.*/\1/') "${required[@]}"; do
    value=${!key:-}
    if [ -z "$value" ] && [ "$key" = APP_KEY ]; then
      value=$(openssl rand -hex 32)
      printf -v APP_KEY '%s' "$value"
      generated_key=$value
    fi
    [ -n "$value" ] || { missing+=("$key"); continue; }
    KEY=$key VALUE=$value perl -pi -e 's/^(\s+\Q$ENV{KEY}\E:\s*).*$/$1"$ENV{VALUE}"/' "$file"
  done
  [ ${#missing[@]} -eq 0 ] || die "$app needs ${missing[*]}, pass them as environment variables"
}

in_ct() { pct exec "$1" -- bash -c "$2"; }

wait_http() {
  local id=$1 ip code i
  [ -n "$port" ] || port=$(sed -nE 's/^\s+- "?([0-9]+):[0-9]+"?.*$/\1/p' "$work/compose.yaml" | head -1)
  for i in $(seq 1 100); do
    ip=$(in_ct "$id" "hostname -I" | awk '{print $1}')
    if [ -n "$ip" ] && [ -n "$port" ]; then
      for s in $scheme http https; do
        code=$(curl -sk -o /dev/null -m 5 -w '%{http_code}' "$s://$ip:$port/" || true)
        case "$code" in 2* | 3* | 401 | 403) echo "$s://$ip:$port"; return 0 ;; esac
      done
    fi
    sleep 3
  done
  return 1
}

install_app() {
  load "$1"
  find_ct >/dev/null && die "$app already runs in container $(find_ct), use: compose.sh update $app"
  work=$(mktemp -d)
  trap 'rm -rf "$work"' EXIT
  curl -fsSL "$url" -o "$work/compose.yaml"
  generated_key=""
  fill_compose "$work/compose.yaml"
  local tpl id
  tpl=$(template)
  id=${CTID:-$(pvesh get /cluster/nextid)}
  say "creating container $id"
  pct create "$id" "$tpl" --hostname "$app" --tags compose-app --memory "$memory" --cores "${CORES:-2}" \
    --rootfs "${STORAGE:-local-lvm}:$disk" --net0 "name=eth0,bridge=${BRIDGE:-vmbr0},${NET:-ip=dhcp}" \
    --unprivileged 1 --features nesting=1,keyctl=1 --onboot 1 >/dev/null
  pct start "$id"
  for _ in $(seq 1 30); do in_ct "$id" "getent hosts deb.debian.org" >/dev/null 2>&1 && break; sleep 2; done
  say "installing Docker"
  in_ct "$id" "export DEBIAN_FRONTEND=noninteractive LC_ALL=C; apt-get update -qq && apt-get install -y -qq curl ca-certificates && curl -fsSL https://get.docker.com | sh" >/dev/null 2>&1 ||
    die "installing Docker in container $id failed"
  in_ct "$id" "mkdir -p /opt/$app"
  pct push "$id" "$work/compose.yaml" "/opt/$app/compose.yaml"
  say "starting $app"
  in_ct "$id" "cd /opt/$app && docker compose --progress quiet up -d"
  local where
  where=$(wait_http "$id") || die "container $id started, but $app does not answer; see: pct exec $id -- docker compose -f /opt/$app/compose.yaml logs"
  say "$app runs in container $id: $where"
  [ -z "$generated_key" ] || say "APP_KEY is $generated_key, keep a copy somewhere other than this server"
}

update_app() {
  load "$1"
  local id
  id=$(find_ct) || die "$app is not installed by this script"
  say "updating Docker and $app in container $id"
  in_ct "$id" "export DEBIAN_FRONTEND=noninteractive LC_ALL=C; apt-get update -qq && apt-get upgrade -y -qq" >/dev/null 2>&1 ||
    die "the package update in container $id failed; see: pct exec $id -- apt-get upgrade"
  in_ct "$id" "cd /opt/$app && docker compose --progress quiet pull && docker compose --progress quiet up -d && docker image prune -f >/dev/null"
  work=$(mktemp -d)
  trap 'rm -rf "$work"' EXIT
  pct pull "$id" "/opt/$app/compose.yaml" "$work/compose.yaml"
  local where
  where=$(wait_http "$id") || die "$app does not answer after the update; see: pct exec $id -- docker compose -f /opt/$app/compose.yaml logs"
  say "$app runs in container $id: $where"
}

case "${1:-}" in
install) install_app "${2:?usage: compose.sh install <app>}" ;;
update) update_app "${2:?usage: compose.sh update <app>}" ;;
list) echo "$APPS" | tr ' ' '\n' ;;
*) echo "usage: compose.sh install|update|list <app>"; exit 1 ;;
esac
