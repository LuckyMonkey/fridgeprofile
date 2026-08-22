#!/usr/bin/env bash
# Profile system, packages, services, containers, drivers, and hardware.
# The report intentionally avoids raw environment variables and full inspect
# payloads because those often contain credentials.

set -euo pipefail

OUTPUT="${1:-snapshots/server_profile_$(date -u +%Y%m%d_%H%M%SZ).txt}"
mkdir -p "$(dirname "$OUTPUT")"

run_if_present() {
  local label="$1"
  shift

  echo "=== ${label} ==="
  if command -v "$1" >/dev/null 2>&1; then
    "$@" || echo "Command failed: $*"
  else
    echo "$1 not installed"
  fi
  echo
}

{
  echo "Generated: $(date -u --iso-8601=seconds)"
  echo

  echo "=== OS Information ==="
  if command -v lsb_release >/dev/null 2>&1; then
    lsb_release -a
  else
    cat /etc/os-release
  fi

  echo

  echo "=== Kernel Information ==="
  uname -a
  echo

  run_if_present "CPU Information" lscpu
  run_if_present "Memory Information" free -h
  run_if_present "Block Devices" lsblk
  run_if_present "Filesystem Usage" df -hT
  run_if_present "PCI Devices" lspci
  run_if_present "USB Devices" lsusb
  run_if_present "Loaded Kernel Modules" lsmod

  echo "=== APT Packages ==="
  if command -v dpkg-query >/dev/null 2>&1; then
    dpkg-query -W -f='${binary:Package}\t${Version}\n' | sort
  else
    echo "dpkg-query not installed"
  fi
  echo

  echo "=== Enabled systemd Services ==="
  if command -v systemctl >/dev/null 2>&1; then
    systemctl list-unit-files --type=service --state=enabled --no-pager || echo "Unable to query systemd services"
  else
    echo "systemctl not installed"
  fi
  echo

  echo "=== Network Addresses ==="
  if command -v ip >/dev/null 2>&1; then
    ip -brief addr || echo "Unable to query network addresses"
  else
    echo "ip not installed"
  fi
  echo

  echo "=== Docker Information ==="
  if command -v docker >/dev/null 2>&1; then
    docker version || true
    echo
    echo "--- Docker Images ---"
    docker images --digests || echo "Unable to query Docker images"
    echo
    echo "--- Docker Containers ---"
    docker ps -a --no-trunc || echo "Unable to query Docker containers"
    for cid in $(docker ps -aq 2>/dev/null || true); do
      echo
      echo "--- Inspecting container $cid ---"
      docker inspect --format 'Name={{.Name}}
Image={{.Config.Image}}
Entrypoint={{json .Config.Entrypoint}}
Command={{json .Config.Cmd}}
RestartPolicy={{.HostConfig.RestartPolicy.Name}}
NetworkMode={{.HostConfig.NetworkMode}}
Ports={{json .NetworkSettings.Ports}}
Mounts={{json .Mounts}}' "$cid" || true
    done
    echo
    echo "--- Docker Compose Files ---"
    find /home/freezer -path /home/freezer/fridgeprofile -prune -o \
      \( -name compose.yml -o -name compose.yaml -o -name docker-compose.yml -o -name docker-compose.yaml \) \
      -type f -print 2>/dev/null | sort
  else
    echo "Docker not installed"
  fi
} > "$OUTPUT"

echo "Profile saved to $OUTPUT"
