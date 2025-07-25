#!/bin/bash
# Profile system, docker containers, drivers, hardware info

OUTPUT="server_profile_$(date +%Y%m%d_%H%M%S).txt"

{
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
  echo "=== CPU Information ==="
  if command -v lscpu >/dev/null 2>&1; then
    lscpu
  fi

  echo
  echo "=== Memory Information ==="
  free -h

  echo
  echo "=== Block Devices ==="
  lsblk

  echo
  echo "=== PCI Devices ==="
  if command -v lspci >/dev/null 2>&1; then
    lspci
  fi

  echo
  echo "=== USB Devices ==="
  if command -v lsusb >/dev/null 2>&1; then
    lsusb
  fi

  echo
  echo "=== Loaded Kernel Modules ==="
  lsmod

  echo
  echo "=== Docker Information ==="
  if command -v docker >/dev/null 2>&1; then
    docker info
    echo
    echo "--- Docker Images ---"
    docker images
    echo
    echo "--- Docker Containers ---"
    docker ps -a
    for cid in $(docker ps -aq); do
      echo
      echo "--- Inspecting container $cid ---"
      docker inspect $cid
    done
  else
    echo "Docker not installed"
  fi
} > "$OUTPUT"

echo "Profile saved to $OUTPUT"
