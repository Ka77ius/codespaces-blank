#!/usr/bin/env bash

# burn_image.sh - burn an ISO or disk image to a target block device
# Usage: ./burn_image.sh /path/to/image.iso /dev/sdX
# Example: sudo ./burn_image.sh ubuntu.iso /dev/sdb

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <image-file> <target-device>"
  echo "Example: sudo $0 ubuntu.iso /dev/sdb"
  exit 1
fi

IMAGE="$1"
TARGET="$2"

if [[ ! -f "$IMAGE" ]]; then
  echo "Error: image file '$IMAGE' does not exist." >&2
  exit 1
fi

if [[ ! -b "$TARGET" ]]; then
  echo "Error: target '$TARGET' is not a block device." >&2
  exit 1
fi

read -rp "WARNING: This will overwrite '$TARGET'. Continue? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Aborted."
  exit 1
fi

if ! command -v pv >/dev/null 2>&1; then
  echo "Warning: pv not installed. Progress will not be shown."
  dd if="$IMAGE" of="$TARGET" bs=4M status=progress conv=fsync
else
  pv "$IMAGE" | dd of="$TARGET" bs=4M conv=fsync status=none
fi

sync

echo "Image burned to $TARGET successfully."
