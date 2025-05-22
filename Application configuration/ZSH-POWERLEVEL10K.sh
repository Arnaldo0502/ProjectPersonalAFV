#!/bin/bash

# === COLORES PARA SALIDA BONITA ===
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}💻 INSTALANDO ZSH...${NC}"
sudo apt install -y zsh
chsh -s $(which zsh)

echo -e "${GREEN}📦 INSTALANDO OH MY ZSH...${NC}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo -e "${GREEN}🎨 INSTALANDO POWERLEVEL10K...${NC}"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
"${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

echo -e "${GREEN}🔤 INSTALANDO FUENTES MESLO NERD FONT...${NC}"
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

echo -e "${GREEN}✅ TERMINAL PERSONALIZADO CON ZSH + POWERLEVEL10K.${NC}"
echo -e "${GREEN}💡 Ahora puedes ejecutar: ${NC}p10k configure"

