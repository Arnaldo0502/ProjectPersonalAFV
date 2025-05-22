#!/bin/bash
echo "UPATE & UPGRADE"
sudo apt update -y && sudo apt upgrade -y
read -p "Press Enter to continue..."


echo "INSTALL ESSENTIALS"
sudo apt install build-essential python3-pip openjdk-17-jdk nmap flatpak git curl libfuse2 rsync unzip zenity whiptail bash wget -y

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
read -p "Press Enter to continue..."


echo "INSTALL APT APLICATIONS"
sudo apt install gnome-tweaks gnome-shell gnome-shell-extensions menulibre gparted ufw gufw obs-studio gimp steam -y
read -p "Press Enter to continue..."


echo "CONFIGURATE EXTENSIONS PACK"
cd ~/.local/share/
sudo rm -R gnome-shell/ 
cd ~/Descargas
wget "https://github.com/Arnaldo0502/ProjectPersonalAFV/raw/main/Application%20configuration/gnome-shell.zip"
unzip gnome-shell.zip
mv gnome-shell ~/.local/share/
sudo rm -R gnome-shell.zip
read -p "Press Enter to continue..."


echo "INSTALL SNAP APPLICATIONS"
sudo apt install -y snapd
sudo snap install core
sudo snap install brave
sudo snap install code
sudo snap install spotify
read -p "Press Enter to continue..."


echo "INSTALL EMUDECK"
curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh | bash

echo "Installation completed successfully!"

