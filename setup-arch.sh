#!/usr/bin/env bash

# Script to setup an android build environment on Arch Linux and derivative distributions

clear
echo '[*] Starting Arch-based Android build setup...'

# Uncomment the multilib repo, incase it was commented out
echo '[1/5] Enabling multilib repo'
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

# Sync, update, and prepare system
echo '[2/5] Syncing repositories and updating system packages'
sudo pacman -Syyu --noconfirm --needed git git-lfs multilib-devel base-devel fontconfig ttf-droid

# Install android build prerequisites
echo '[3/5] Installing Android building prerequisites'
packages="ncurses5-compat-libs lib32-ncurses5-compat-libs aosp-devel xml2 lineageos-devel"
for package in $packages; do
    echo "Installing $package"
    git clone https://aur.archlinux.org/"$package"
    cd "$package" || exit
    makepkg -si --skippgpcheck --noconfirm --needed
    cd - || exit
    rm -rf "$package"
done

# Install adb and associated udev rules
echo '[4/5] Installing adb convenience tools'
sudo pacman -S --noconfirm --needed android-tools android-udev

# Install essential tools

# Install adb and associated udev rules
echo '[5/5] Installing AUR Package manager (yay)'
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -S postman-bin visual-studio-code-bin plank chromium google-chrome jetbrains-toolbox

echo '[DONE] Setup completed'