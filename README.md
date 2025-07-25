# Server Profiling Script

This repository contains a simple script to profile a server running Ubuntu. It collects information about installed software, hardware, drivers and Docker configuration.

## Usage

Run the script on the target machine:

```bash
./profile_server.sh
```

A text report will be generated in the current directory with a timestamped filename (`server_profile_YYYYMMDD_HHMMSS.txt`).

The script relies on standard utilities such as `lsb_release`, `lscpu`, `lsblk`, `lspci`, `lsusb`, `lsmod`, and `docker`. Ensure these are installed for the most complete report.
