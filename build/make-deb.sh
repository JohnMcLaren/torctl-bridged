#!/bin/bash

TOR_UID="debian-tor"

DEBFULLNAME=""
DEBEMAIL=""
DEBNAME="torctl-bridged"
DEBVERSION="0.5.7-1"
DEBSECTION="net"
DEBHOMEPAGE="https://github.com/JohnMcLaren/torctl-bridged/"
DEBARCH="amd64" # List all: dpkg-architecture -L
DEBDEPENDS="tor,iptables"
DEBRECOMMENDS="obfs4proxy|snowflake-client|jq"
DEBSUGGESTS=""
DEBCONFLICTS="torctl"
DEBREPLACES="torctl"
DEBDESCRIPTION="Script to redirect all traffic through Tor network including DNS queries for anonymizing entire system. \
  This version of the script supports adding bridges (input nodes) in case you have problems connecting to the Tor network."
DEBDIR="$DEBNAME"_"$DEBVERSION"_"$DEBARCH"

set -e
echo -e "Build: $DEBDIR.deb"
echo -e "Date: `date +"%d.%m.%y %T"`\n"
rm -rf SHA256SUMS

### Create directories ###

mkdir -p $DEBDIR/DEBIAN
mkdir -p $DEBDIR/etc/systemd/system/
mkdir -p $DEBDIR/usr/share/bash-completion/completions/
mkdir -p $DEBDIR/usr/local/bin/
mkdir -p $DEBDIR/usr/bin/

### Create links to release files (hard-links only) ###

ln ../service/* $DEBDIR/etc/systemd/system/
ln ../bash-completion/torctl $DEBDIR/usr/share/bash-completion/completions/torctl
ln ../PT/webtunnel/release/build/-/webtunnel-client $DEBDIR/usr/bin/webtunnel-client 2>/dev/null || echo -e "\e[93m[ WARN ]\e[39m Plugin 'webtunnel-client' was not found and will not be included in this release package."
ln ../torctl $DEBDIR/usr/local/bin/

### Create links to pre/postinst shells ###

ln ./postinst.sh $DEBDIR/DEBIAN/postinst

### Patch TOR_UID & shell version ###

sed -i $DEBDIR/usr/local/bin/torctl \
    -e 's/VERSION=".*"/VERSION="torctl.sh v'$DEBVERSION' (bridged)"/' \
    -e 's/TOR_UID="tor"/TOR_UID="'$TOR_UID'"/'

### Create md5sums & calc install size ###

cd $DEBDIR
md5sum $(find * -type f -not -path 'DEBIAN/*') > DEBIAN/md5sums
DEBINSTALLSIZE=`du -sk --exclude=DEBIAN . | cut -f1`
cd ..

### Create Debian control file ###

cat << EOF | grep ': ..*' | tee "$DEBDIR/DEBIAN/control"
Package: $DEBNAME
Source: $DEBNAME ($DEBVERSION)
Version: $DEBVERSION
Architecture: $DEBARCH
Maintainer: $DEBFULLNAME <$DEBEMAIL>
Installed-Size: $DEBINSTALLSIZE
Description: $DEBDESCRIPTION
Section: $DEBSECTION
Priority: optional
Homepage: $DEBHOMEPAGE
Depends: $DEBDEPENDS
Recommends: $DEBRECOMMENDS
Suggests: $DEBSUGGESTS
Conflicts: $DEBCONFLICTS
Replaces: $DEBREPLACES
EOF

### Build deb package ###

dpkg-deb --build --root-owner-group $DEBDIR

### Write package/s checksum ###

sha256sum $DEBDIR.deb >> SHA256SUMS

### Cleanup ###

rm -rf $DEBDIR

echo -e "\n--- Done ---"


