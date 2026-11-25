#!/usr/bin/env bash
# Runs one of junkerderprovinz's container images as a Proxmox VE application
# container (OCI image as LXC, Proxmox VE 9.1 or newer).
#
#   image.sh install <app>    pull the image, create /srv/<app>, create and start the container
#   image.sh update <app>     pull the image again and replace the container, keeping its folders and address
#   image.sh list             show the apps this script knows
#
# Settings come from the environment: CTID, STORAGE (default local-lvm),
# TEMPLATE_STORAGE (default local), BRIDGE (default vmbr0), NET (default
# ip=dhcp, for example "ip=192.168.1.50/24,gw=192.168.1.1"), CORES, MEMORY.
# Values an app requires are passed the same way, for example
# IDM_ADMIN_PASSWORD=... for OpenCloud.
set -euo pipefail

app_catalog() {
  case "$1" in
  arrowloop)
    image=docker.io/junkerderprovinz/arrowloop:latest port=8422 path=/ memory=512
    dirs=("config:/config:100000" "data:/data:100000")
    envs=() ;;
  castleparcel)
    image=docker.io/junkerderprovinz/castleparcel:latest port=3000 path=/ memory=512
    dirs=("data:/data:100000" "config:/config:100000")
    envs=("CONFIG_DIR=/config" "DEFAULT_EXPIRY=7d" "MAX_FILE_SIZE=0" "MAX_EXPIRY=never" "STORAGE_QUOTA=0" "RATE_LIMIT=true" "TRUST_PROXY=false") ;;
  parleyport)
    image=docker.io/junkerderprovinz/parleyport:latest port=8760 path=/health memory=256
    dirs=("data:/var/lib/parleyport:100099:100100")
    envs=() ;;
  trickwork)
    image=ghcr.io/junkerderprovinz/trickwork:latest port=3210 path=/ memory=256
    dirs=()
    envs=("PORT=3210") ;;
  knightloader)
    image=docker.io/junkerderprovinz/knightloader:latest port=8749 path=/api/health memory=1536
    dirs=("data:/data:100000" "downloads:/data/downloads:100000")
    envs=("UMASK=022") ;;
  cannoncommander)
    image=docker.io/junkerderprovinz/cannoncommander:latest port=80 path=/health memory=1024 features=fuse=1,nesting=1
    dirs=("config:/config:100000")
    envs=("PUID=1000" "PGID=1000" "UMASK=022") ;;
  excalidraw)
    image=docker.io/junkerderprovinz/excalidraw:latest port=80 path=/ memory=512
    dirs=("config:/config:100000")
    envs=("ENABLE_LIBRARY=false" "ENABLE_AI=false") ;;
  garage)
    image=docker.io/junkerderprovinz/garage:latest port=3909 path=/ memory=512
    dirs=("data:/data:100000" "config:/config:100000")
    envs=("DB_ENGINE=sqlite" "PUID=1000" "PGID=1000") ;;
  juicefs)
    image=docker.io/junkerderprovinz/juicefs:latest port=9000 path=/minio/health/live memory=512
    dirs=("config:/config:100000" "data:/data:100000" "cache:/cache:100000")
    envs=("S3_ROOT_USER=juicefs" "META_URL=sqlite3:///config/juicefs.db" "STORAGE=file" "BUCKET=/data/" "VOLUME_NAME=juicefs" "MULTI_BUCKETS=true" "PUID=1000" "PGID=1000") ;;
  rustdesk)
    image=ghcr.io/junkerderprovinz/rustdesk:latest port=21114 path=/ memory=512
    dirs=("data:/data:100000" "api-data:/app/data:100000")
    envs=("ENCRYPTED_ONLY=1" "MUST_LOGIN=N" "RUSTDESK_API_LANG=en")
    required=("RELAY" "RUSTDESK_API_RUSTDESK_ID_SERVER" "RUSTDESK_API_RUSTDESK_RELAY_SERVER" "RUSTDESK_API_RUSTDESK_API_SERVER") ;;
  securo)
    image=docker.io/junkerderprovinz/securo:latest port=8080 path=/ memory=1536 disk=6
    dirs=("data:/data:100000")
    envs=("BUILTIN_POSTGRES=true" "POSTGRES_USER=postgres" "BUILTIN_REDIS=true" "REGISTRATION_ENABLED=true" "POSTGRES_PORT=5432" "POSTGRES_DB=securo" "REDIS_PORT=6379" "REDIS_DB=0" "TRUSTED_PROXY_HOPS=1" "SIMPLEFIN_ENABLED=false" "OIDC_ENABLED=false" "LOCAL_AUTH_ENABLED=true" "PUID=1000" "PGID=1000") ;;
  opencloud)
    image=docker.io/junkerderprovinz/opencloud:rolling port=9200 path=/ scheme=https memory=2048
    dirs=("config:/etc/opencloud:100000" "data:/var/lib/opencloud:100000")
    envs=("OC_INSECURE=true" "IDM_CREATE_DEMO_USERS=false" "PROXY_TLS=true" "PROXY_ENABLE_APP_AUTH=false" "PUID=1000" "PGID=1000" "STORAGE_USERS_DRIVER=posix" "OFFICE=off" "FULLTEXT_SEARCH=false")
    required=("IDM_ADMIN_PASSWORD" "OC_URL") ;;
  seafile)
    image=docker.io/junkerderprovinz/seafile:latest port=80 path=/ memory=2048 disk=8
    dirs=("shared:/shared:100000")
    envs=("SEAFILE_SERVER_PROTOCOL=http" "BUILTIN_MARIADB=true" "BUILTIN_REDIS=true" "ENABLE_NOTIFICATION_SERVER=false" "OFFICE=off" "ENABLE_SEADOC=false")
    required=("SEAFILE_SERVER_HOSTNAME" "INIT_SEAFILE_ADMIN_EMAIL") ;;
  matrix)
    image=docker.io/junkerderprovinz/matrix:latest port=8008 path=/_matrix/client/versions memory=1536 disk=6
    dirs=("data:/data:100000")
    envs=("REPORT_STATS=no" "ENABLE_FEDERATION=true" "ENABLE_REGISTRATION=false" "AUTH_ENABLED=false" "S3_MEDIA_ENABLED=false" "TURN_PORT=3478" "POSTGRES_PORT=5432" "POSTGRES_USER=matrix" "POSTGRES_DB=matrix" "PUID=1000" "PGID=1000")
    required=("SERVER_NAME" "POSTGRES_HOST" "POSTGRES_PASSWORD") ;;
  euro-office)
    image=ghcr.io/junkerderprovinz/euro-office:latest port=80 path=/healthcheck memory=3072 disk=10
    dirs=("data:/var/www/euro-office/Data:100000" "certs:/certs:100000")
    envs=("WOPI_ENABLED=true" "JWT_ENABLED=true" "USE_UNAUTHORIZED_STORAGE=true")
    required=("JWT_SECRET") ;;
  filebot | handbrake | jdownloader | krusader | prusaslicer | stellarium)
    image=docker.io/junkerderprovinz/$1:latest port=3001 path=/ scheme=https memory=2048 disk=8
    dirs=("config:/config:100000" "storage:/storage:100000")
    envs=("PUID=1000" "PGID=1000" "UMASK=022") ;;
  couchdb)
    image=docker.io/library/couchdb:latest port=5984 path=/_up memory=512
    dirs=("data:/opt/couchdb/data:105984" "local.d:/opt/couchdb/etc/local.d:105984")
    envs=("COUCHDB_USER=admin")
    required=("COUCHDB_PASSWORD") ;;
  pocket-id)
    image=docker.io/pocketid/pocket-id:v2 port=1411 path=/ memory=512
    dirs=("data:/app/data:101000")
    envs=("TRUST_PROXY=false" "PUID=1000" "PGID=1000")
    required=("APP_URL" "ENCRYPTION_KEY") ;;
  rustfs)
    image=docker.io/rustfs/rustfs:latest port=9001 path=/ memory=512
    dirs=("data:/data:100000")
    envs=("RUSTFS_CONSOLE_CORS_ALLOWED_ORIGINS=*" "RUSTFS_OBS_LOGGER_LEVEL=warn")
    required=("RUSTFS_ACCESS_KEY" "RUSTFS_SECRET_KEY") ;;
  seaweedfs)
    image=docker.io/chrislusf/seaweedfs:latest port=9333 path=/cluster/status memory=512
    dirs=("data:/data:100000")
    envs=() ;;
  silo)
    image=docker.io/pgsty/silo:latest port=9001 path=/ memory=512
    dirs=("data:/data:100000")
    envs=()
    required=("MINIO_ROOT_USER" "MINIO_ROOT_PASSWORD")
    command="server /data --console-address :9001" ;;
  standardnotes-webui)
    image=docker.io/standardnotes/web:latest port=80 path=/ memory=256
    dirs=()
    envs=() ;;
  versitygw)
    image=docker.io/versity/versitygw:latest port=7071 path=/ memory=256
    dirs=("data:/data:100000" "config:/config:100000")
    envs=("VGW_BACKEND=posix" "VGW_BACKEND_ARG=/data" "VGW_PORT=:7070" "VGW_WEBUI_PORT=:7071" "VGW_ADMIN_PORT=:7080" "VGW_WEBUI_NO_TLS=true" "VGW_IAM_DIR=/config" "VGW_REGION=us-east-1" "VGW_HEALTH=/_health")
    required=("ROOT_ACCESS_KEY" "ROOT_SECRET_KEY") ;;
  claper)
    image=ghcr.io/claperco/claper:latest port=4000 path=/ memory=1024
    dirs=("uploads:/app/uploads:100000")
    envs=("LANG=C.UTF-8" "ENABLE_ACCOUNT_CREATION=true" "MAX_FILE_SIZE_MB=15" "LANGUAGES=en,fr,es,it,de")
    required=("DATABASE_URL" "SECRET_KEY_BASE" "BASE_URL")
    # Proxmox loses the escaped quotes of the image's own start command.
    entrypoint="sh -c \"/app/bin/claper eval 'Claper.Release.migrate(); Claper.Release.seeds()' && exec /app/bin/claper start\"" ;;
  n8n)
    image=docker.io/n8nio/n8n:latest port=5678 path=/healthz memory=1024
    dirs=("data:/home/node/.n8n:101000")
    envs=("DB_TYPE=postgresdb" "DB_POSTGRESDB_PORT=5432" "DB_POSTGRESDB_DATABASE=n8n" "DB_POSTGRESDB_USER=n8n" "N8N_SECURE_COOKIE=false" "N8N_RUNNERS_ENABLED=true" "N8N_DIAGNOSTICS_ENABLED=false")
    required=("DB_POSTGRESDB_HOST" "DB_POSTGRESDB_PASSWORD" "N8N_HOST" "WEBHOOK_URL") ;;
  *) return 1 ;;
  esac
}

APPS="arrowloop castleparcel parleyport trickwork knightloader cannoncommander excalidraw garage juicefs rustdesk securo opencloud seafile matrix euro-office filebot handbrake jdownloader krusader prusaslicer stellarium couchdb pocket-id rustfs seaweedfs silo standardnotes-webui versitygw n8n claper"

die() { echo "error: $*" >&2; exit 1; }
say() { echo "-> $*"; }

load() {
  app=$1
  image="" port="" path=/ scheme=http memory=512 disk=4 command="" features="" entrypoint=""
  dirs=() envs=() required=()
  app_catalog "$app" || die "unknown app '$app', see: image.sh list"
  memory=${MEMORY:-$memory}
  base=/srv/$app
}

pull_image() {
  local storage=${TEMPLATE_STORAGE:-local} name
  name="$(echo "${image##*/}" | tr ':' '_').tar"
  pveam remove "$storage:vztmpl/$name" >/dev/null 2>&1 || true
  say "pulling $image"
  pvesh create "/nodes/$(hostname)/storage/$storage/oci-registry-pull" --reference "$image" >/dev/null
  template="$storage:vztmpl/$name"
  pveam list "$storage" | grep -q "^$template " || die "pull finished, but $template is missing"
}

write_env() {
  local id=$1 conf=/etc/pve/lxc/$1.conf e
  for e in "${envs[@]}"; do echo "lxc.environment.runtime: $e" >>"$conf"; done
  [ -f "$base/.env" ] || return 0
  while IFS= read -r e; do
    [ -n "$e" ] && echo "lxc.environment.runtime: $e" >>"$conf"
  done <"$base/.env"
}

create_ct() {
  local id=$1 net=$2 i=0 d name target owner
  local args=(--hostname "$app" --memory "$memory" --cores "${CORES:-2}" --rootfs "${STORAGE:-local-lvm}:$disk" --net0 "$net" --unprivileged 1 --onboot 1)
  [ -n "$features" ] && args+=(--features "$features")
  for d in "${dirs[@]}"; do
    IFS=: read -r name target owner group <<<"$d"
    args+=("--mp$i" "$base/$name,mp=$target")
    i=$((i + 1))
  done
  pct create "$id" "$template" "${args[@]}" >/dev/null
  [ -n "$entrypoint" ] && pct set "$id" --entrypoint "$entrypoint" >/dev/null
  [ -n "$command" ] && pct set "$id" --entrypoint "$(sed -n 's/^entrypoint: //p' "/etc/pve/lxc/$id.conf") $command" >/dev/null
  write_env "$id"
}

wait_http() {
  local ip code i
  for i in $(seq 1 60); do
    ip=$(lxc-info -n "$1" -iH 2>/dev/null | grep -v : | head -1)
    if [ -n "$ip" ]; then
      code=$(curl -sk -o /dev/null -m 5 -w '%{http_code}' "$scheme://$ip:$port$path" || true)
      case "$code" in 2* | 3* | 401 | 403) echo "$ip"; return 0 ;; esac
    fi
    pct status "$1" | grep -q running || return 1
    sleep 3
  done
  return 1
}

install_app() {
  load "$1"
  [ -f "$base/.ctid" ] && die "$app is already installed as container $(cat "$base/.ctid"), use: image.sh update $app"
  local missing=() r d name target owner group
  for r in "${required[@]}"; do [ -n "${!r:-}" ] || missing+=("$r"); done
  [ ${#missing[@]} -eq 0 ] || die "$app needs ${missing[*]}, pass them as environment variables"
  mkdir -p "$base"
  : >"$base/.env"
  chmod 600 "$base/.env"
  for r in "${required[@]}"; do echo "$r=${!r}" >>"$base/.env"; done
  for d in "${dirs[@]}"; do
    IFS=: read -r name target owner group <<<"$d"
    mkdir -p "$base/$name"
    chown "$owner:${group:-$owner}" "$base/$name"
  done
  pull_image
  local id=${CTID:-$(pvesh get /cluster/nextid)}
  say "creating container $id"
  create_ct "$id" "name=eth0,bridge=${BRIDGE:-vmbr0},${NET:-ip=dhcp}"
  echo "$id" >"$base/.ctid"
  pct start "$id"
  local ip
  ip=$(wait_http "$id") || die "container $id started, but $app does not answer; see: pct console $id"
  say "$app runs in container $id: $scheme://$ip:$port"
}

update_app() {
  load "$1"
  [ -f "$base/.ctid" ] || die "$app is not installed by this script"
  local old new net ip
  old=$(cat "$base/.ctid")
  net=$(sed -n 's/^net0: //p' "/etc/pve/lxc/$old.conf" | sed 's/,host-managed=1//')
  pull_image
  new=${CTID:-$(pvesh get /cluster/nextid)}
  say "replacing container $old with $new"
  pct shutdown "$old" --timeout 60 >/dev/null 2>&1 || pct stop "$old"
  create_ct "$new" "$net"
  pct start "$new"
  if ip=$(wait_http "$new"); then
    pct destroy "$old" --purge >/dev/null
    echo "$new" >"$base/.ctid"
    say "$app runs in container $new: $scheme://$ip:$port"
  else
    pct stop "$new" >/dev/null 2>&1 || true
    pct start "$old"
    die "the new container $new does not answer, $old runs again; see: pct console $new"
  fi
}

case "${1:-}" in
install) install_app "${2:?usage: image.sh install <app>}" ;;
update) update_app "${2:?usage: image.sh update <app>}" ;;
list) echo "$APPS" | tr ' ' '\n' ;;
*) sed -n '2,13s/^# \{0,1\}//p' "$0" 2>/dev/null || echo "usage: image.sh install|update|list <app>"; exit 1 ;;
esac
