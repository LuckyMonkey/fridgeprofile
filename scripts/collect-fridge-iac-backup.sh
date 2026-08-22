#!/usr/bin/env bash
# Build a curated, Git-safe fridge infrastructure backup tree.
#
# Run from the repository root. For the complete backup, run as root or with
# enough permissions to read /home/fridge, /etc, /opt/rocketchat, and EFI
# metadata. The script deliberately excludes runtime data and secrets.

set -euo pipefail

STAMP="${1:-$(date -u +%Y%m%dT%H%M%SZ)}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${ROOT}/generated/fridge-iac-${STAMP}"

mkdir -p \
  "${OUT}/home/fridge" \
  "${OUT}/infra/systemd" \
  "${OUT}/infra/network" \
  "${OUT}/infra/boot/EFI/ubuntu" \
  "${OUT}/infra/apps/rocketchat" \
  "${OUT}/manifests"

copy_if_readable() {
  local src="$1"
  local dst="$2"

  if [ -r "$src" ]; then
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst"
  else
    printf 'SKIP unreadable: %s\n' "$src" >> "${OUT}/manifests/skipped.txt"
  fi
}

redact_env() {
  local src="$1"
  local dst="$2"

  if [ ! -r "$src" ]; then
    printf 'SKIP unreadable env: %s\n' "$src" >> "${OUT}/manifests/skipped.txt"
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  {
    printf '# Redacted from %s on %s\n' "$src" "$STAMP"
    awk -F= '
      /^[[:space:]]*#/ { print; next }
      /^[A-Za-z_][A-Za-z0-9_]*=/ { print $1"=<redacted>"; next }
      NF { print "# redacted non-assignment line" }
    ' "$src"
  } > "$dst"
}

redact_netplan() {
  local src="$1"
  local dst="$2"

  if [ ! -r "$src" ]; then
    printf 'SKIP unreadable netplan: %s\n' "$src" >> "${OUT}/manifests/skipped.txt"
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  sed -E 's/(password:[[:space:]]*).*/\1"<redacted>"/' "$src" > "$dst"
}

copy_rocketchat() {
  local base="/opt/rocketchat"
  local dst="${OUT}/infra/apps/rocketchat"

  for path in \
    .env.example .gitignore README.md docker.yml podman.yml podman-rootful.yml \
    compose.yml compose.database.yml compose.drachtio.yml \
    compose.freeswitch.external.yml compose.freeswitch.yml \
    compose.manual-cert.traefik.yml compose.monitoring.yml compose.nats.yml \
    compose.traefik.yml \
    generated/docker-compose.yml generated/docker-compose-no-traefik.yml \
    docs/external-mongo.md docs/external-nats.md docs/external-service-metrics.md \
    files/loki/config.yaml files/opentelemetry/config.yaml files/prometheus/prometheus.yml \
    .github/workflows/generate-aio.yaml
  do
    copy_if_readable "${base}/${path}" "${dst}/${path}"
  done

  redact_env "${base}/.env" "${dst}/.env.redacted"
}

copy_home_fridge() {
  local base="/home/fridge"
  local dst="${OUT}/home/fridge"

  if [ ! -d "$base" ]; then
    printf 'SKIP missing: %s\n' "$base" >> "${OUT}/manifests/skipped.txt"
    return 0
  fi

  tar -C "$base" -cf - \
    --exclude='.bash_history' \
    --exclude='*.env' \
    --exclude='.env' \
    --exclude='*.pem' \
    --exclude='*.key' \
    --exclude='*.crt' \
    --exclude='*cli_pw*' \
    --exclude='node_modules' \
    --exclude='node_modules/*' \
    --exclude='deploy-backups' \
    --exclude='deploy-backups/*' \
    --exclude='*.backup.*' \
    --exclude='public/*.bundle.js' \
    --exclude='*.tar' \
    --exclude='*.tar.gz' \
    --exclude='*.tar.zst' \
    --exclude='*.iso' \
    --exclude='*.db' \
    --exclude='*.db-*' \
    --exclude='*.sqlite' \
    --exclude='*.sqlite-*' \
    --exclude='*.log' \
    --exclude='fridge-recovery/backups' \
    --exclude='fridge-recovery/backups/*' \
    --exclude='fridge-recovery/opentracker/state' \
    --exclude='fridge-recovery/opentracker/state/*' \
    --exclude='fridge-agents/pihole/etc-pihole' \
    --exclude='fridge-agents/pihole/etc-pihole/*' \
    bin \
    fridge-recovery/scripts \
    fridge-recovery/package-policy \
    fridge-recovery/opentracker \
    fridge-recovery/manifests \
    fridge-recovery/torrents \
    fridge-recovery/serve \
    fridge-agents rocketchat-gpt-bridge \
    fridge-ai-context fridge-homepage 2>> "${OUT}/manifests/skipped.txt" \
    | tar -C "$dst" -xf -

  redact_env "${base}/rocketchat-gpt-bridge/.env" \
    "${OUT}/home/fridge/rocketchat-gpt-bridge/.env.redacted"
  redact_env "${base}/fridge-agents/pihole/.env" \
    "${OUT}/home/fridge/fridge-agents/pihole/.env.redacted"
}

collect_inventory() {
  {
    printf 'Generated: %s\n\n' "$STAMP"
    uname -a || true
    printf '\n'
    lsb_release -a 2>/dev/null || cat /etc/os-release
  } > "${OUT}/manifests/host-summary.txt"

  if command -v dpkg-query >/dev/null 2>&1; then
    dpkg-query -W -f='${binary:Package}\t${Version}\n' | sort \
      > "${OUT}/manifests/apt-packages.tsv"
  fi

  if command -v docker >/dev/null 2>&1; then
    {
      docker version || true
      printf '\n--- Docker images ---\n'
      docker images --digests || true
      printf '\n--- Docker containers ---\n'
      docker ps -a --no-trunc || true
    } > "${OUT}/manifests/docker-inventory.txt" 2>&1
  fi

  find "$OUT" -type f | sort | sed "s#^${OUT}/##" > "${OUT}/manifests/file-list.txt"
  find "$OUT" -type f -print0 | sort -z | xargs -0 sha256sum \
    > "${OUT}/manifests/SHA256SUMS"
}

copy_if_readable /etc/systemd/system/fridge-pihole.service \
  "${OUT}/infra/systemd/fridge-pihole.service"
copy_if_readable /etc/systemd/system/fridge-startup-success-tone.service \
  "${OUT}/infra/systemd/fridge-startup-success-tone.service"

redact_netplan /etc/netplan/00-installer-config.yaml \
  "${OUT}/infra/network/00-installer-config.redacted.yaml"
redact_netplan /etc/netplan/50-cloud-init.yaml \
  "${OUT}/infra/network/50-cloud-init.redacted.yaml"

if command -v efibootmgr >/dev/null 2>&1; then
  efibootmgr -v > "${OUT}/infra/boot/efibootmgr-v.txt" 2>&1 || true
fi
find /boot/efi/EFI -maxdepth 4 -type f -printf '%p\t%s bytes\n' 2>/dev/null | sort \
  > "${OUT}/infra/boot/efi-file-list.txt" || true
copy_if_readable /boot/efi/EFI/ubuntu/grub.cfg \
  "${OUT}/infra/boot/EFI/ubuntu/grub.cfg"
copy_if_readable /boot/efi/EFI/ubuntu/BOOTX64.CSV \
  "${OUT}/infra/boot/EFI/ubuntu/BOOTX64.CSV"

copy_rocketchat
copy_home_fridge
collect_inventory

printf 'Wrote curated backup tree: %s\n' "$OUT"
