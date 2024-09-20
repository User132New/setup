#!/usr/bin/env bash

# Copyright (C) 2018 Harsh 'MSF Jarvis' Shandilya
# Copyright (C) 2018 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only

# Script to setup an AOSP Build environment on Ubuntu and Linux Mint
LATEST_MAKE_VERSION="4.3"
UBUNTU_16_PACKAGES="libesd0-dev"
UBUNTU_20_PACKAGES="libncurses5 libncurses5-dev libncursesw5-dev curl python-is-python3"
UBUNTU_22_PACKAGES="libncurses5 libncurses5-dev libncursesw5-dev curl python-is-python3"
UBUNTU_24_PACKAGES="libncurses5 libncurses5-dev libncursesw5-dev curl python-is-python3 zip unzip openjdk-17-jdk"
DEBIAN_10_PACKAGES="libncurses5 libncurses5-dev libncursesw5-dev curl"
DEBIAN_11_PACKAGES="libncurses5 libncurses5-dev libncursesw5-dev curl"
PACKAGES=""
EXTRA_PACKAGES=${1}

# Install curl and GNUPG first
echo "[+] Installing curl and GNUPG"
sudo apt update
sudo apt install curl gnupg1 gnupg2 -y

# Install lsb-core packages
sudo apt install lsb-core -y

LSB_RELEASE="$(lsb_release -d | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//')"

if [[ ${LSB_RELEASE} =~ "Mint 18" || ${LSB_RELEASE} =~ "Ubuntu 16" ]]; then
    PACKAGES="${UBUNTU_16_PACKAGES}"
elif [[ ${LSB_RELEASE} =~ "Ubuntu 20" || ${LSB_RELEASE} =~ "Ubuntu 21" ]]; then
    PACKAGES="${UBUNTU_20_PACKAGES}"
elif [[ ${LSB_RELEASE} =~ "Ubuntu 22" || ${LSB_RELEASE} =~ "Ubuntu 23" ]]; then
    PACKAGES="${UBUNTU_22_PACKAGES}"
elif [[ ${LSB_RELEASE} =~ "Ubuntu 24" ]]; then
    PACKAGES="${UBUNTU_24_PACKAGES}"
elif [[ ${LSB_RELEASE} =~ "Debian GNU/Linux 10" ]]; then
    PACKAGES="${DEBIAN_10_PACKAGES}"
elif [[ ${LSB_RELEASE} =~ "Debian GNU/Linux 11" ]]; then
    PACKAGES="${DEBIAN_11_PACKAGES}"
fi

#echo "[+] Adding GitHub apt key and repository!"
#sudo apt install software-properties-common -y
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
#sudo apt-add-repository https://cli.github.com/packages

sudo apt update

sudo DEBIAN_FRONTEND=noninteractive \
    apt install \
    adb autoconf automake axel bc bison build-essential \
    ccache clang cmake expat fastboot flex g++ \
    g++-multilib gawk gcc gcc-multilib git gnupg gperf \
    htop imagemagick lib32ncurses5-dev lib32z1-dev libtinfo5 libc6-dev libcap-dev \
    libexpat1-dev libgmp-dev '^liblz4-.*' '^liblzma.*' libmpc-dev libmpfr-dev libncurses5-dev \
    libsdl1.2-dev libssl-dev libtool libxml2 libxml2-utils '^lzma.*' lzop \
    maven ncftp ncurses-dev patch patchelf pkg-config pngcrush \
    pngquant python2.7 python-all-dev re2c schedtool squashfs-tools subversion \
    texinfo unzip w3m xsltproc zip zlib1g-dev lzip \
    libxml-simple-perl apt-utils dwarves dialog x11-xserver-utils dnsutils lld libelf-dev jq axel \
    ${PACKAGES} ${EXTRA_PACKAGES} -y


echo -e "[+] Setting up udev rules for adb!"
sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
sudo chmod 644 /etc/udev/rules.d/51-android.rules
sudo chown root /etc/udev/rules.d/51-android.rules
sudo systemctl restart udev

if [[ "$(command -v make)" ]]; then
    makeversion="$(make -v | head -1 | awk '{print $3}')"
    if [[ ${makeversion} != "${LATEST_MAKE_VERSION}" ]]; then
        echo "[+] Installing make ${LATEST_MAKE_VERSION} instead of ${makeversion}"
        bash "$(dirname "$0")"/make.sh "${LATEST_MAKE_VERSION}"
    fi
fi

echo "[+] Installing Akebi"
git clone https://github.com/herobuxx/akebi
cd akebi
sudo make
sudo make install

echo "[+] Installing repo"
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod a+rx /usr/local/bin/repo

echo "[DONE] Setup finished"
