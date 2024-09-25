#!/bin/bash

TOR_UID="debian-tor"

DEBFULLNAME=""
DEBEMAIL=""
DEBNAME="torctl-bridged"
DEBVERSION="0.5.7-1"
DEBSECTION="Networking"
DEBHOMEPAGE="https://github.com/JohnMcLaren/torctl-bridged/"
DEBARCH="amd64" # List all: dpkg-architecture -L
DEBDEPENDS="tor,iptables"
DEBRECOMMENDS="obfs4proxy|snowflake-client"
DEBSUGGESTS=""
DEBCONFLICTS=""
DEBREPLACES="torctl"
DEBDESCRIPTION="Script to redirect all traffic through Tor network including DNS queries for anonymizing entire system. \
 This version of the script supports adding bridges (input nodes) in case you have problems connecting to the Tor network."
DEBDIR="$DEBNAME"_"$DEBVERSION"_"$DEBARCH"

echo "--- build: $DEBDIR.deb ---"
set -e
rm -rf SHA256SUMS

### Create directories ###

mkdir -p $DEBDIR/etc/systemd/system/
mkdir -p $DEBDIR/usr/share/bash-completion/completions/
mkdir -p $DEBDIR/usr/local/bin/

### Copy release files ###

cp -r ../service/* $DEBDIR/etc/systemd/system/
cp ../bash-completion/torctl $DEBDIR/usr/share/bash-completion/completions/torctl
cp ../webtunnel/release/build/-/webtunnel-client $DEBDIR/usr/local/bin/webtunnel-client 2>/dev/null || echo "[WARN] The webtunnel-client plugin was not found and will not be included in this release package."
cp ../torctl $DEBDIR/usr/local/bin/

### Patch TOR_UID & shell version ###

sed -i $DEBDIR/usr/local/bin/torctl \
    -e 's/VERSION=".*"/VERSION="torctl.sh v'$DEBVERSION' (bridged)"/' \
    -e 's/TOR_UID="tor"/TOR_UID="'$TOR_UID'"/'

### Create Debian control file ###

mkdir -p $DEBDIR/DEBIAN
cat << EOF | grep ': ..*' | tee "$DEBDIR/DEBIAN/control"
Package: $DEBNAME
Version: $DEBVERSION
Maintainer: $DEBFULLNAME <$DEBEMAIL>
Description: $DEBDESCRIPTION
Section: $DEBSECTION
Priority: optional
Architecture: $DEBARCH
Homepage: $DEBHOMEPAGE
Depends: $DEBDEPENDS
Recommends: $DEBRECOMMENDS
Suggests: $DEBSUGGESTS
Conflicts: $DEBCONFLICTS
Replaces: $DEBREPLACES
EOF

### Build deb package ###

dpkg-deb --build --root-owner-group $DEBDIR

### Create package/s checksum ###

sha256sum $DEBDIR.deb >> SHA256SUMS

### Cleanup ###

rm -rf $DEBDIR

echo "--- done ---"


