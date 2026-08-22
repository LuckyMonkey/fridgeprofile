# Fridge Restore Notes

1. Install Ubuntu Server matching the captured host snapshot.
2. Restore boot order from `infra/boot/efibootmgr-v-*.txt` manually with
   `efibootmgr` after verifying disk GUIDs on the new machine.
3. Restore systemd units from `infra/systemd/` and run `systemctl daemon-reload`.
4. Restore `/home/fridge` scripts and source from `home/fridge/` or decode the
   curated archive in `infra/archives/`.
5. Recreate secret values from a password manager or local notes; do not expect
   this repo to contain live `.env` values.
6. Deploy app services from compose files under `home/fridge` and
   `infra/apps/rocketchat`.
7. Run the health checks in `home/fridge/fridge-recovery/scripts/`, especially
   `fridge-self-check.sh`, `boot-integrity-check.sh`, and
   `recovery-torrent-status.sh`.
