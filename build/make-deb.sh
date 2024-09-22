#!/bin/bash

TOR_UID="debian-tor"

DEBFULLNAME=""
DEBEMAIL=""
DEBNAME="torctl"
DEBVERSION="0.5.7-bridged"
DEBARCH="amd64"
DEBDESCRIPTION="Script to redirect all traffic through Tor network including DNS queries for anonymizing entire system. \
This version of the script supports adding bridges (input nodes) in case you have problems connecting to the Tor network."
DEBDIR="$DEBNAME"_"$DEBVERSION"_"$DEBARCH"

echo "--- build: $DEBDIR.deb ---"
set -e
### Create directories ###

mkdir -p $DEBDIR/etc/systemd/system/
mkdir -p $DEBDIR/usr/share/bash-completion/completions/
mkdir -p $DEBDIR/usr/local/bin/

### Copy release files ###

cp -r ../service/* $DEBDIR/etc/systemd/system/
cp ../bash-completion/torctl $DEBDIR/usr/share/bash-completion/completions/torctl
cp ../webtunnel/release/build/-/webtunnel-client $DEBDIR/usr/local/bin/webtunnel-client 2>/dev/null || echo "[WARN] The webtunnel-client plugin was not found and will not be included in this release package."
cp ../torctl $DEBDIR/usr/local/bin/

### Patch TOR_UID ###

find $DEBDIR/usr/local/bin/ -name $DEBNAME -type f -exec sed -i 's/TOR_UID="tor"/TOR_UID="'$TOR_UID'"/' {} \;

### Create Debian control file ###

mkdir -p $DEBDIR/DEBIAN
cat > "$DEBDIR/DEBIAN/control" << EOF
Package: $DEBNAME
Version: $DEBVERSION
Priority: optional
Architecture: $DEBARCH
Depends: 
Maintainer: $DEBFULLNAME <$DEBEMAIL>
Description: $DEBDESCRIPTION
EOF

### Build deb package ###

dpkg-deb --build --root-owner-group $DEBDIR

### Create package/s checksum ###

sha256sum $DEBDIR.deb > SHA256SUMS

### Cleanup ###

rm -rf $DEBDIR

echo "--- done ---"


