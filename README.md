# Fridge Profile

This repository is a lightweight backup of the fridge host profile: machine
inventory, package/service lists, container metadata, and the small amount of
checked-in user configuration needed to recreate the environment.

Sensitive runtime state is intentionally excluded. Do not commit Codex auth,
session databases, shell history, raw Docker inspect payloads, private keys, or
environment files.

## Usage

Run the script on the target machine:

```bash
./profile_server.sh
```

A text report will be generated under `snapshots/` with a UTC timestamped
filename:

```text
snapshots/server_profile_YYYYMMDD_HHMMSSZ.txt
```

The script relies on standard utilities such as `lsb_release`, `lscpu`,
`lsblk`, `lspci`, `lsusb`, `lsmod`, `systemctl`, `dpkg-query`, `ip`, and
`docker`. Missing utilities are reported rather than treated as fatal errors.
