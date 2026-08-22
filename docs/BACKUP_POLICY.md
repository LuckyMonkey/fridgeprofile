# Fridge IaC Backup Policy

This repository is for reproducible infrastructure and recovery code, not raw
machine images or secret storage.

## Include

- Custom scripts and agent docs from `/home/fridge`.
- Application source and compose files for local services.
- Systemd units that define fridge services.
- Redacted network configuration templates.
- EFI/NVRAM text metadata, including `efibootmgr -v` output and EFI file lists.
- Package, Docker, and host inventory text where readable.
- Restore notes, manifests, and checksums.

## Exclude

- `.env` values, API tokens, passwords, private keys, certificates, and Pi-hole
  `cli_pw`.
- Shell history, Codex auth/session/state/log databases, and cache directories.
- MongoDB, Pi-hole, and other runtime databases.
- Node modules, generated bundles, logs, previous full backup archives, and
  mounted data volumes.
- EFI binaries in Git; store file lists and text loader configs instead.

## Repeatable Process

Run this from the repository root:

```bash
sudo ./scripts/collect-fridge-iac-backup.sh
```

Review the generated tree under `generated/fridge-iac-<timestamp>/`, scan it
for secrets, then copy the wanted changes into the tracked repo paths and commit
them.

When Git shell auth is unavailable, publish a text archive such as
`infra/archives/fridge-home-iac-curated-YYYYMMDD.tar.gz.b64` through the GitHub
connector and keep the extracted tree locally for review.
