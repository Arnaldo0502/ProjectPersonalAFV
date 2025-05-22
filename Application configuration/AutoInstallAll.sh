#!/bin/bash

# === COLORES PARA SALIDA BONITA ===
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}▶️ ACTUALIZANDO SISTEMA...${NC}"
sudo apt update -y && sudo apt upgrade -y

echo -e "${GREEN}▶️ INSTALANDO HERRAMIENTAS DE ESCRITORIO...${NC}"
sudo apt install -y gnome-tweaks gnome-shell gnome-shell-extensions menulibre

echo -e "${GREEN}▶️ INSTALANDO GRUB CUSTOMIZER...${NC}"
sudo add-apt-repository -y ppa:danielrichter2007/grub-customizer
sudo apt update
sudo apt install -y grub-customizer

echo -e "${GREEN}▶️ INSTALANDO ZSH, CURL Y GIT...${NC}"
sudo apt install -y zsh curl git
chsh -s $(which zsh)

echo -e "${GREEN}▶️ INSTALANDO OH MY ZSH...${NC}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo -e "${GREEN}▶️ INSTALANDO POWERLEVEL10K...${NC}"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

echo -e "${GREEN}▶️ DESCARGANDO FUENTE MESLO NERD FONT...${NC}"
TEMP_FONT_DIR="/tmp/meslo-font"
mkdir -p "$TEMP_FONT_DIR"
cd "$TEMP_FONT_DIR"
wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip -O meslo.zip
unzip -q meslo.zip -d meslo
mkdir -p ~/.local/share/fonts
cp meslo/*.ttf ~/.local/share/fonts/
fc-cache -f -v
cd ~
rm -rf "$TEMP_FONT_DIR"
echo -e "${GREEN}✔️ FUENTES INSTALADAS.${NC}"

echo -e "${GREEN}▶️ INSTALANDO APLICACIONES VÍA SNAP...${NC}"
sudo apt install -y snapd
sudo snap install core
sudo snap install brave
sudo snap install code --classic
sudo snap install spotify

echo -e "${GREEN}▶️ INSTALANDO HERRAMIENTAS DE SISTEMA Y MULTIMEDIA...${NC}"
sudo apt install -y gparted ufw gufw obs-studio gimp steam

echo -e "${GREEN}▶️ INSTALANDO HERRAMIENTAS DE DESARROLLO...${NC}"
sudo apt install -y build-essential python3-pip openjdk-17-jdk nmap

echo -e "${GREEN}▶️ INSTALANDO DEPENDENCIAS PARA EMUDECK...${NC}"
sudo apt install -y bash flatpak git jq libfuse2 rsync unzip zenity whiptail

echo -e "${GREEN}▶️ INSTALANDO EMUDECK...${NC}"
curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh | bash

echo -e "${GREEN}✅ INSTALACIÓN COMPLETA.${NC}"
echo -e "${RED}💡 Reinicia el sistema y luego ejecuta 'p10k configure' para personalizar Powerlevel10k.${NC}"

