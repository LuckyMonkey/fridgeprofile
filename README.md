# Fridge Profile

This repository is a lightweight backup of the fridge host profile: machine
inventory, package/service lists, container metadata, and the small amount of
checked-in user configuration needed to recreate the environment.

Sensitive runtime state is intentionally excluded. Do not commit Codex auth,
session databases, shell history, raw Docker inspect payloads, private keys, or
environment files.

## Backup Workflow

The repeatable collector is checked in at:

```bash
sudo ./scripts/collect-fridge-iac-backup.sh
```

It builds a curated backup tree under `generated/` and follows the policy in
`docs/BACKUP_POLICY.md`. Review the generated tree, scan for secrets, then copy
approved changes into the tracked repo paths and commit.

Current tracked areas include:

- `home/fridge/`: curated custom scripts, agents, app source, and runbooks.
- `infra/systemd/`: custom service units.
- `infra/network/`: redacted network templates.
- `infra/boot/`: EFI/NVRAM text metadata and text loader configs.
- `infra/apps/rocketchat/`: Rocket.Chat compose/docs/config, excluding live data.
- `infra/archives/`: text-safe curated archive artifacts and checksums.

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
