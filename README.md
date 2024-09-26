## Description

Script to redirect all traffic through the `Tor` network, including DNS-requests for anonymize entire system.
This version of the script supports adding bridges (input nodes) in case you have problems connecting to the `Tor` network.  
Bridging protocols camouflage `Tor` traffic, allowing it to pass through censored networks.

Currently supported bridge types:
- obfs4
- snowflake
- webtunnel

## Installation

1. Install `Tor` and client-plugins for connecting to bridges of `Tor` network 
(`webtunnel` plugin is included in the `torctl-bridged` package):
```sh
$> sudo apt install tor obfs4proxy snowflake-client
```

2. Download the `torctl-bridged` deb-package and the `SHA256SUMS` checksum file from the [Release][release-url] section. Install the `torctl-bridged` package:

```sh
# Check package checksum:
$> sha256sum -c SHA256SUMS

# Install package:
$> sudo apt install ./torctl_0.5.7-bridged_amd64.deb
-OR-
$> sudo dpkg -i ./torctl_0.5.7-bridged_amd64.deb

# Remove package:
$> sudo apt purge torctl
-OR-
$> sudo dpkg --purge torctl

```

## Usage

* ### Start `torctl` without bridges

```sh
$> sudo torctl start
```

* ### Start `torctl` with bridges

Create a file with bridge addresses, for example `1.bridges`:

```sh
obfs4 151.67.213.75:8080 0D0E74E2FDE5C41D16F8C79969E37E8978AD066C cert=nE2vFIzUzjoyUstscXBFKe88SjlM/IIwR9+AddX7uCyoIXwe26d2c3TzypCqeLjfdoWRYg iat-mode=0
obfs4 185.192.124.64:993 978180445CF4B1748DBD2FEE550F93BE8C117AF9 cert=bfZhNvbOb4XNnpY7htuwQv5Folg6uNmQzT7OQIwN5H9QeRHVjMPPjhk+VvPL5b+xb5A3GQ iat-mode=0
```
- The bridge file name can be any
- Each bridge address is added to the file on a **new line**
- The number of addresses in the file is unlimited
- Bridge addresses of different types can be in one file
- Addresses of bridges can be obtained on the website [torproject.org][bridges-url]  
or to your **e-mail** by sending a letter **with empty subject** to bridges@torproject.org and the message **"get transport obfs4"**
  > Please note that letters are accepted only from the `Riseup` or `Gmail` servers.

Next, use the created bridges file when you start `torctl`:

```sh
$> sudo torctl start --bridges ./1.bridges
```

* ###  Restart `torctl` with bridges

```sh
$> sudo torctl restart --bridges ./1.bridges
```

* ###  Stop `torctl`

```sh
$> sudo torctl stop
```
* ### Log of `Tor` work
```sh
$> sudo journalctl -f -u tor@default
<Ctrl + C> - abort
```

### All `torctl` commands

```sh
$ torctl
--==[ torctl.sh by blackarch.org ]==--

Usage: torctl.sh COMMAND

A script to redirect all traffic through tor network

Commands:
  start                    - start tor and redirect all traffic through tor
  start --bridges <file>   - start tor with bridges
  stop                     - stop tor and redirect all traffic through clearnet
  status                   - get tor service status
  restart                  - restart tor and traffic rules
  restart --bridges <file> - restart tor with bridges
  bridges                  - print used bridges
  autowipe                 - enable memory wipe at shutdown
  autostart                - start torctl at startup
  ip                       - get remote ip address
  chngid                   - change tor identity
  chngmac                  - change mac addresses of all interfaces
  rvmac                    - revert mac addresses of all interfaces
  version                  - print version of torctl and exit

```

### Building the `torctl` package

If you intend to modify the `torctl` script and create your own deb-package based on it, then in the [build][build-url] directory you will find the `make-deb.sh` script that will help you with this.

### Adding a Tor repository

To get the latest versions of `Tor`, add the [torproject][torproject-url] repository to your system.  
**[IMPORTANT]** The [torproject.org][torproject-url] resource must be available in your region/country.

```sh
### Get utilities ###
$> sudo apt install wget gpg apt-transport-tor

### Add key and repo [Debian / Kali Linux] ###
$> wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | \
sudo tee /usr/share/keyrings/deb.torproject.org-keyring.gpg > /dev/null && \
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] \
https://deb.torproject.org/torproject.org stable main
deb-src [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] \
https://deb.torproject.org/torproject.org stable main" | sudo tee /etc/apt/sources.list.d/tor.list > /dev/null

 -OR-

### Add key and repo [Ubuntu / Linux Mint] ###
$> wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | \
sudo tee /usr/share/keyrings/deb.torproject.org-keyring.gpg > /dev/null && \
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] \
https://deb.torproject.org/torproject.org jammy main
deb-src [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] \
https://deb.torproject.org/torproject.org jammy main" | sudo tee /etc/apt/sources.list.d/tor.list > /dev/null

### Update repo sources ###
$> sudo apt update

### Install Tor and debian keyring tool ###
$> sudo apt install tor deb.torproject.org-keyring

### Check Tor version ###
$> tor --version
```

## Get Involved

You can get in touch with the BlackArch Linux team. Just check out the following:

**Please, send us pull requests!**

**Web:** https://www.blackarch.org/

**Mail:** team@blackarch.org

**IRC:** [irc://irc.freenode.net/blackarch](irc://irc.freenode.net/blackarch)

[release-url]: https://github.com/JohnMcLaren/torctl-bridged/releases
[build-url]: https://github.com/JohnMcLaren/torctl-bridged/tree/master/build/
[bridges-url]: https://bridges.torproject.org/options
[torproject-url]: https://www.torproject.org/
