#!/usr/bin/env bash

# Update xbps
xbps-install -Syu xbps

# clone git repos for arch install environment
git clone https://github.com/archlinux/arch-install-scripts.git
git clone https://github.com/archlinux/archlinux-keyring.git

# install deps
xbps-install -y asciidoc make findutils pkgconf sequoia-sq curl pacman

# config arch-install-scripts
cd arch-install-scripts
make && make install
echo "Arch Linux installd scripts (pacstrap, genfstab, and arch-chroot) successfully installed."
cd ..

# config archlinux-keyring
cd archlinux-keyring
./keyringctl build
PREFIX=/usr make install
echo "Arch Linux keyring successfully installed and populated."
cd ..

# config pacman environment
mkdir /etc/pacman.d
curl "https://archlinux.org/mirrorlist/?country=US&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on" > /etc/pacman.d/mirrorlist
sed -i 's/#Server/Server/g' /etc/pacman.d/mirrorlist
sed -i 's/#UseSyslog/UseSyslog/' /etc/pacman.conf
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -i 's/#CheckSpace/CheckSpace/' /etc/pacman.conf
sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
sed -i 's/#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
cat <<EOF >> /etc/pacman.conf
[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF

# config pacman-key
pacman-key --init
pacman-key --populate archlinux

# clean up
rm -rf arch-install-scripts
rm -rf archlinux-keyring

echo "Arch Linux pacman is now ready to be used."
