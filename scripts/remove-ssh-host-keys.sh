#!/usr/bin/env bash
# Remove SSH host keys from a sample root filesystem archive (.tbz2).
#
# Installing openssh-server while nv_build_samplefs.sh builds the sample rootfs
# generates SSH host keys, so every system built from the archive would share
# them. Without host keys, sshd does not start until each system generates its
# own on first boot.
#
# GNU tar deletes the key members from the decompressed stream, so every other
# member keeps its ownership and mode. Requires GNU tar and bzip2.
set -euo pipefail

archive=${1:?usage: $0 ARCHIVE.tbz2}
pattern='^(\./)?etc/ssh/ssh_host_'

members=$(tar -tjf "$archive")
keys=$(grep -E "$pattern" <<<"$members" || true)
if [ -z "$keys" ]; then
  echo "No SSH host keys in $archive"
  exit 0
fi

echo "Removing SSH host keys from $archive:"
echo "$keys"

tmp="$archive.tmp"
trap 'rm -f "$tmp"' EXIT
bzip2 -dc "$archive" |
  tar --delete -f - --verbatim-files-from --files-from=<(printf '%s\n' "$keys") |
  bzip2 -c >"$tmp"
mv "$tmp" "$archive"

members=$(tar -tjf "$archive")
if grep -E "$pattern" <<<"$members"; then
  echo "SSH host keys remain in $archive" >&2
  exit 1
fi
