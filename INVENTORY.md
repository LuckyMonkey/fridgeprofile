# Fridge Backup Inventory

Last refreshed: 2026-08-22 UTC

## Captured

- `profile_server.sh`: repeatable host inventory script.
- `snapshots/`: current generated host profile with OS, kernel, hardware, package, service, filesystem, and Docker metadata where readable.
- `dotfiles/`: login shell defaults from `/home/freezer`.
- `codex/`: non-secret Codex configuration metadata.
- `scripts/collect-fridge-iac-backup.sh`: reproducible curated backup collector.
- `docs/`: backup policy and restore notes.
- `home/fridge/`: custom fridge scripts, agents, app source, and runbooks, excluding live secrets and runtime data.
- `infra/systemd/`: custom fridge systemd units.
- `infra/network/`: redacted netplan templates.
- `infra/boot/`: EFI boot order metadata and text bootloader config.
- `infra/apps/rocketchat/`: Rocket.Chat compose/docs/config, excluding `.env` and MongoDB data.
- `infra/archives/`: text-safe curated archive of `/home/fridge` code/config and checksums.

## Deliberately Excluded

- `.codex/auth.json`
- Codex session, state, memory, goal, history, and log databases
- Codex plugin caches and temporary files
- Raw Docker inspect JSON and environment variables
- Private keys, tokens, `.env` files, and other local secrets
- Wi-Fi passwords and other network secrets
- Runtime databases, app data volumes, logs, dependency folders, generated bundles, and previous large backup archives
- EFI binaries; only text metadata and file lists are committed

## Restore Notes

Use the profile snapshot as an inventory guide, then copy the dotfiles back into
`/home/freezer` as needed. Recreate credentials through the owning tools rather
than restoring them from Git.

For a full fridge restore, start with `docs/RESTORE_NOTES.md`.
