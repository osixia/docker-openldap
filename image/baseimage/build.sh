#!/bin/sh -ex

## Add bash tools to /sbin
ln -s /container/tool/* /sbin/

mkdir -p /container/service
mkdir -p /container/environment /container/environment/startup
chmod 700 /container/environment/ /container/environment/startup

groupadd -g 8377 docker_env

# dpkg options
cp /container/file/dpkg_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc
cp /container/file/dpkg_nolocales /etc/dpkg/dpkg.cfg.d/01_nolocales

# General config
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive
MINIMAL_APT_GET_INSTALL='apt-get install -y --no-install-recommends'

## Prevent initramfs updates from trying to run grub and lilo.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
export INITRD=no
printf no > /container/environment/INITRD

apt-get update

## Fix some issues with APT packages.
## See https://github.com/dotcloud/docker/issues/1024
dpkg-divert --local --rename --add /sbin/initctl
ln -sf /bin/true /sbin/initctl

## Replace the 'ischroot' tool to make it always return true.
## Prevent initscripts updates from breaking /dev/shm.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## https://bugs.launchpad.net/launchpad/+bug/974584
dpkg-divert --local --rename --add /usr/bin/ischroot
ln -sf /bin/true /usr/bin/ischroot

## Install apt-utils.
$MINIMAL_APT_GET_INSTALL apt-utils apt-transport-https ca-certificates locales procps dirmngr gnupg iproute2 python3-minimal python3-yaml

## Upgrade all packages.
apt-get dist-upgrade -y --no-install-recommends -o Dpkg::Options::="--force-confold"

# fix locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen en_US
update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

printf en_US.UTF-8 > /container/environment/LANG
printf en_US.UTF-8 > /container/environment/LANGUAGE
printf en_US.UTF-8 > /container/environment/LC_CTYPE

apt-get clean
rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*

# Remove useless files
rm -rf /container/file
rm -rf /container/build.sh /container/Dockerfile
