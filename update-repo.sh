#!/bin/sh
# Regenerates the Sileo index files from the .deb files in debs/.
set -e
cd "$(dirname "$0")"
BASE="https://whoisrez.github.io/whoisrez-repo"
dpkg-scanpackages -m debs /dev/null 2>/dev/null > Packages.tmp
# Add an icon to each package that has one in icons/.
python3 - "$BASE" <<'PY'
import sys, os
base = sys.argv[1]
icons = {'com.whoisrez.bitlifeeditor': 'icons/bitlifeeditor.png'}
out = []
for block in open('Packages.tmp').read().strip().split('\n\n'):
    pkg = next((l.split(': ', 1)[1] for l in block.splitlines() if l.startswith('Package: ')), '')
    if pkg in icons and os.path.exists(icons[pkg]): block += f'\nIcon: {base}/{icons[pkg]}'
    out.append(block)
open('Packages', 'w').write('\n\n'.join(out) + '\n')
PY
rm Packages.tmp
bzip2 -kf Packages
gzip -kf9 Packages
{
  echo "Origin: whoisrez"
  echo "Label: whoisrez"
  echo "Suite: stable"
  echo "Version: 1.0"
  echo "Codename: whoisrez"
  echo "Architectures: iphoneos-arm64"
  echo "Components: main"
  echo "Description: Tweaks and tools by whoisrez"
  echo "MD5Sum:"
  for f in Packages Packages.bz2 Packages.gz; do echo " $(md5sum $f | cut -d' ' -f1) $(stat -c%s $f) $f"; done
  echo "SHA256:"
  for f in Packages Packages.bz2 Packages.gz; do echo " $(sha256sum $f | cut -d' ' -f1) $(stat -c%s $f) $f"; done
} > Release
echo "Repo updated: $(grep -c '^Package:' Packages) package(s)"
