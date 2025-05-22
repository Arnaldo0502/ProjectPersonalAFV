#!/bin/bash

# === COLORES PARA SALIDA BONITA ===
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}▶️ ACTUALIZANDO SISTEMA...${NC}"
sudo apt update -y && sudo apt upgrade -y

# -------------------------------
# 1. HERRAMIENTAS NECESARIAS
# -------------------------------
echo -e "${GREEN}🔧 INSTALANDO HERRAMIENTAS DE DESARROLLO...${NC}"
sudo apt install -y \
  build-essential \
  python3-pip \
  openjdk-17-jdk \
  nmap \
  flatpak \
  git \
  curl \
  libfuse2 \
  rsync \
  unzip \
  zenity \
  whiptail \
  bash

echo -e "${GREEN}🔐 ACTIVANDO REPOSITORIO FLATHUB...${NC}"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# -------------------------------
# 2. APLICACIONES DE USUARIO
# -------------------------------
echo -e "${GREEN}📦 INSTALANDO APLICACIONES DE ESCRITORIO...${NC}"
sudo apt install -y \
  gnome-tweaks \
  gnome-shell \
  gnome-shell-extensions \
  menulibre \
  gparted \
  ufw \
  gufw \
  obs-studio \
  gimp \
  steam

# --- EXTENSIONES PERSONALIZADAS ---
echo -e "${GREEN}📦 DESCARGANDO Y APLICANDO EXTENSIONES PERSONALIZADAS...${NC}"
# Descargar el ZIP
sudo curl -L "https://github.com/Arnaldo0502/ProjectPersonalAFV/raw/main/Application%20configuration/gnome-shell.zip" -o /tmp/gnome-shell.zip
# Descomprimir y sobrescribir en el directorio de extensiones (global)
sudo unzip -o /tmp/gnome-shell.zip -d /usr/share/gnome-shell/extensions/
# Eliminar el ZIP temporal
sudo rm /tmp/gnome-shell.zip

echo -e "${GREEN}📥 INSTALANDO APLICACIONES VÍA SNAP...${NC}"
sudo apt install -y snapd
sudo snap install core
sudo snap install brave
sudo snap install code --classic
sudo snap install spotify

echo -e "${GREEN}🎮 INSTALANDO EMUDECK...${NC}"
curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh | bash

echo -e "${GREEN}✅ INSTALACIÓN BASE COMPLETA.${NC}"
