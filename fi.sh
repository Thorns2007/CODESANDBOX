#!/bin/bash
# Automate Firefox install from Mozilla APT repository (Debian-based)

set -e

echo "=== Membuat direktori keyrings jika belum ada ==="
sudo install -d -m 0755 /etc/apt/keyrings

echo "=== Mengunduh dan mengimpor Mozilla APT signing key ==="
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | \
sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

echo "=== Verifikasi fingerprint key ==="
FINGERPRINT=$(gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc \
  | awk '/pub/{getline; gsub(/^ +| +$/,""); print}')

EXPECTED="35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3"

if [ "$FINGERPRINT" = "$EXPECTED" ]; then
  echo "Fingerprint cocok: $FINGERPRINT"
else
  echo "Fingerprint TIDAK cocok!"
  echo "Ditemukan: $FINGERPRINT"
  echo "Diharapkan: $EXPECTED"
  exit 1
fi

echo "=== Menambahkan Mozilla repository ==="
cat <<EOF | sudo tee /etc/apt/sources.list.d/mozilla.sources
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF

echo "=== Mengatur prioritas APT ==="
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

echo "=== Update repository & install Firefox ==="
sudo apt-get update
sudo apt-get install -y firefox

echo "=== Selesai! Firefox berhasil diinstal. ==="
