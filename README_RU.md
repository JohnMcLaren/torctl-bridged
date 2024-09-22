## Описание

Скрипт для перенаправления всего трафика через сеть `Tor`, включая DNS-запросы для анонимизации всей системы.
Эта версия скрипта поддерживает добавление мостов (входных нод) на случай, если у вас возникнут проблемы с подключением к сети `Tor`.
Протоколы мостов камуфлируют трафик `Tor` позволяя ему проходить через цензурируемые сети.

На данный момент поддерживаются типы мостов:
- obfs4
- snowflake
- webtunnel


## Установка

1. Установить `Tor` и клиент-плагины для подключения к мостам сети `Tor` 
(плагин `webtunnel` включен в состав пакета `torctl-bridged`):

```sh
$> sudo apt install tor obfs4proxy snowflake-client
```

2. Скачать deb-пакет `torctl-bridged` и файл контрольной суммы `SHA256SUMS` из раздела [Release][release-url]. Установить пакет `torctl-bridged`:

```sh
# Проверить контрольную сумму пакета:
$> sha256sum -c SHA256SUMS

# Установить пакет:
$> sudo apt install ./torctl_0.5.7-bridged_amd64.deb
-ИЛИ-
$> sudo dpkg -i ./torctl_0.5.7-bridged_amd64.deb

# Для удаления пакета выполнить:
$> sudo apt purge torctl
-ИЛИ-
$> sudo dpkg --purge torctl

```

## Использование

* ###  Запуск `torctl` без мостов

```sh
$> sudo torctl start
```

* ###  Запуск `torctl` с мостами

Создайте файл с адресами мостов, например `1.bridges`:

```sh
obfs4 151.67.213.75:8080 0D0E74E2FDE5C41D16F8C79969E37E8978AD066C cert=nE2vFIzUzjoyUstscXBFKe88SjlM/IIwR9+AddX7uCyoIXwe26d2c3TzypCqeLjfdoWRYg iat-mode=0
obfs4 185.192.124.64:993 978180445CF4B1748DBD2FEE550F93BE8C117AF9 cert=bfZhNvbOb4XNnpY7htuwQv5Folg6uNmQzT7OQIwN5H9QeRHVjMPPjhk+VvPL5b+xb5A3GQ iat-mode=0
```
- Имя файла мостов может быть любым
- Адрес каждого моста добавляется в файл с новой строки
- Количество адресов в файле неограничено
- Адреса мостов разных типов могут быть в одном файле
- Адреса мостов можно получить на сайте [torproject.org][bridges-url] или на свой **e-mail** отправив письмо **с пустой темой** на bridges@torproject.org и сообщением **"get transport obfs4"**.
Обратите внимание, письма принимаются только с серверов `Riseup` или `Gmail`.

Далее, используйте созданный файл при запуске `torctl`:
```sh
$> sudo torctl start --bridges ./1.bridges
```

* ###  Перезапуск `torctl` с мостами

```sh
$> sudo torctl restart --bridges ./1.bridges
```

* ###  Остановка `torctl`

```sh
$> sudo torctl stop
```
* ### Журнал работы `Tor`
```sh
$> sudo journalctl -f -u tor@default
<Ctrl + C> - прервать
```

###  Все команды `torctl`

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
  autowipe                 - enable memory wipe at shutdown
  autostart                - start torctl at startup
  ip                       - get remote ip address
  chngid                   - change tor identity
  chngmac                  - change mac addresses of all interfaces
  rvmac                    - revert mac addresses of all interfaces
  version                  - print version of torctl and exit

```

### Сборка пакета `torctl`

Если вы намерены изменить скрипт `torctl` и создать на его основе свой deb-пакет то в директории [build][build-url] вы найдете скрипт `make-deb.sh` который поможет вам в этом.

### Добавление репозитория Tor

Для получения свежих версий `Tor`, добавьте репозиторий [torproject][torproject-url] в свою систему.  
**[ВАЖНО]** Ресурс [torproject.org][torproject-url] должен быть доступен в вашем регионе/стране.

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


