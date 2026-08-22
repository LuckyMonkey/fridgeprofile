# Archive Artifacts

`fridge-home-iac-curated-20260822.tar.gz.b64` is a text-safe archive of the
curated `/home/fridge` backup payload. It excludes secrets, runtime databases,
dependency folders, generated bundles, logs, previous backup archives, and
certificates.

Decode it with:

```bash
base64 -d fridge-home-iac-curated-20260822.tar.gz.b64 > fridge-home-iac-curated-20260822.tar.gz
tar -tzf fridge-home-iac-curated-20260822.tar.gz
```

Note: the complete artifact exists in local commit `f11820d` in
`/home/freezer/fridgeprofile`. Publishing the 388 KB `.b64` file through the
connector was not completed because normal Git HTTPS auth is unavailable in this
shell.
