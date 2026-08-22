# Fridge Backup Inventory

Last refreshed: 2026-08-22 UTC

## Captured

- `profile_server.sh`: repeatable host inventory script.
- `snapshots/`: current generated host profile with OS, kernel, hardware, package, service, filesystem, and Docker metadata where readable.
- `dotfiles/`: login shell defaults from `/home/freezer`.
- `codex/`: non-secret Codex configuration metadata.

## Deliberately Excluded

- `.codex/auth.json`
- Codex session, state, memory, goal, history, and log databases
- Codex plugin caches and temporary files
- Raw Docker inspect JSON and environment variables
- Private keys, tokens, `.env` files, and other local secrets

## Restore Notes

Use the profile snapshot as an inventory guide, then copy the dotfiles back into
`/home/freezer` as needed. Recreate credentials through the owning tools rather
than restoring them from Git.
