#!/bin/bash

# Variables
ODOO_USER="odoo17"
ODOO_DIR="/opt/odoo17"
ODOO_ADDONS="$ODOO_DIR/odoo17-custom-addons"
ODOO_LOG="/var/log/odoo17.log"
ODOO_CONF="/etc/odoo17.conf"
ODOO_SERVICE="/etc/systemd/system/odoo17.service"
ODOO_PASSWORD="Password"  # Change this to your password

print_progress_bar() {
    local percent=$1
    local message=$2
    local filled=$(( (percent * 20) / 100 ))
    local empty=$(( 20 - filled ))
    printf "["
    printf "%${filled}s" | tr ' ' '#'
    printf "%${empty}s" | tr ' ' ' '
    printf "] %3d%% %s\r" "$percent" "$message"
}

start_progress() {
    export CURRENT_STEP=0
    export TOTAL_STEPS=$1
    export PROGRESS_LABEL=$2
    print_progress_bar 0 "$PROGRESS_LABEL"
}

update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percent=$(( (CURRENT_STEP * 100) / TOTAL_STEPS ))
    print_progress_bar "$percent" "$PROGRESS_LABEL"
    if [ $percent -eq 100 ]; then
        echo
    fi
}

# Display header
echo "Starting Odoo17 installation..."
echo ""

# Step 1: Update the system
start_progress 2 "Updating system packages"
sudo apt-get update -y > /dev/null 2>&1
update_progress
sudo apt-get upgrade -y > /dev/null 2>&1
update_progress

# Step 2: Install Python and required libraries
start_progress 1 "Installing Python dependencies"
sudo apt-get install -y python3-pip python3-dev python3-venv libxml2-dev libxslt1-dev zlib1g-dev \
libsasl2-dev libldap2-dev build-essential libssl-dev libffi-dev libmysqlclient-dev libjpeg-dev \
libpq-dev libjpeg8-dev liblcms2-dev libblas-dev libatlas-base-dev > /dev/null 2>&1
update_progress

# Step 3: Install NPM and CSS plugins
start_progress 2 "Setting up NPM tools"
sudo apt-get install -y npm > /dev/null 2>&1
update_progress
sudo ln -s /usr/bin/nodejs /usr/bin/node > /dev/null 2>&1
sudo npm install -g less less-plugin-clean-css > /dev/null 2>&1
sudo apt-get install -y node-less > /dev/null 2>&1
update_progress

# Step 4: Install libssl1.1 and fonts
start_progress 4 "Installing system dependencies"
wget -q http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb
update_progress
sudo dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb > /dev/null 2>&1
update_progress
wget -q http://archive.ubuntu.com/ubuntu/pool/universe/x/xfonts-75dpi/xfonts-75dpi_1.0.4+nmu1_all.deb
wget -q http://archive.ubuntu.com/ubuntu/pool/main/x/xfonts-base/xfonts-base_1.0.5_all.deb
update_progress
sudo dpkg -i xfonts-75dpi_1.0.4+nmu1_all.deb > /dev/null 2>&1
sudo dpkg -i xfonts-base_1.0.5_all.deb > /dev/null 2>&1
update_progress

# Step 5: Install Wkhtmltopdf
start_progress 2 "Installing Wkhtmltopdf"
sudo wget -q https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bionic_amd64.deb
update_progress
sudo dpkg -i wkhtmltox_0.12.6-1.bionic_amd64.deb > /dev/null 2>&1
sudo apt install -f -y > /dev/null 2>&1
update_progress

# Step 6: Install PostgreSQL
start_progress 2 "Configuring PostgreSQL"
sudo apt-get install postgresql -y > /dev/null 2>&1
update_progress
sudo systemctl start postgresql > /dev/null 2>&1 && sudo systemctl enable postgresql > /dev/null 2>&1
update_progress

# Step 7: Create users
start_progress 3 "Creating system users"
sudo useradd -m -U -r -d $ODOO_DIR -s /bin/bash $ODOO_USER > /dev/null 2>&1
update_progress
echo "$ODOO_USER:$ODOO_PASSWORD" | sudo chpasswd > /dev/null 2>&1
sudo usermod -aG sudo $ODOO_USER > /dev/null 2>&1
update_progress
sudo su - postgres -c "createuser -s $ODOO_USER" > /dev/null 2>&1
update_progress

# Step 8: Install Odoo
start_progress 5 "Installing Odoo 17"
sudo -u $ODOO_USER git clone https://www.github.com/odoo/odoo --depth 1 --branch 17.0 $ODOO_DIR/odoo17 > /dev/null 2>&1
update_progress
sudo -u $ODOO_USER bash -c "cd $ODOO_DIR; python3 -m venv odoo17-venv" > /dev/null 2>&1
update_progress
sudo -u $ODOO_USER bash -c "source $ODOO_DIR/odoo17-venv/bin/activate; pip install --upgrade pip wheel" > /dev/null 2>&1
update_progress
sudo -u $ODOO_USER bash -c "source $ODOO_DIR/odoo17-venv/bin/activate; pip install -r $ODOO_DIR/odoo17/requirements.txt" > /dev/null 2>&1
update_progress
sudo mkdir -p $ODOO_ADDONS $(dirname $ODOO_LOG) > /dev/null 2>&1
sudo touch $ODOO_LOG > /dev/null 2>&1
sudo chown -R $ODOO_USER:$ODOO_USER $ODOO_ADDONS $ODOO_LOG > /dev/null 2>&1
update_progress

# Step 9: Create config
start_progress 1 "Creating config file"
sudo bash -c "cat > $ODOO_CONF" <<EOL > /dev/null 2>&1
[options]
admin_passwd = $ODOO_PASSWORD
db_host = False
db_port = False
db_user = $ODOO_USER
db_password = False
xmlrpc_port = 8069
logfile = $ODOO_LOG
addons_path = $ODOO_DIR/odoo17/addons,$ODOO_ADDONS
EOL
sudo chown $ODOO_USER:$ODOO_USER $ODOO_CONF > /dev/null 2>&1
sudo chmod 640 $ODOO_CONF > /dev/null 2>&1
update_progress

# Step 10: Service setup
start_progress 4 "Configuring system service"
sudo bash -c "cat > $ODOO_SERVICE" <<EOL > /dev/null 2>&1
[Unit]
Description=Odoo17
After=network.target postgresql.service

[Service]
Type=simple
SyslogIdentifier=odoo17
PermissionsStartOnly=true
User=$ODOO_USER
Group=$ODOO_USER
ExecStart=$ODOO_DIR/odoo17-venv/bin/python3 $ODOO_DIR/odoo17/odoo-bin -c $ODOO_CONF
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOL
update_progress
sudo systemctl daemon-reload > /dev/null 2>&1
update_progress
sudo systemctl start odoo17 > /dev/null 2>&1
update_progress
sudo systemctl enable odoo17 > /dev/null 2>&1
update_progress

# Final information
SERVER_IP=$(hostname -I | awk '{print $1}')
echo ""
echo "════════════════════════════════════════════════"
echo "               ODOO 17 SETUP COMPLETE           "
echo "════════════════════════════════════════════════"
echo "  Access URL:     http://$SERVER_IP:8069        "
echo "  Admin Password: $ODOO_PASSWORD                "
echo "════════════════════════════════════════════════"
echo "  Database User:  $ODOO_USER                    "
echo "  Install Path:   $ODOO_DIR                     "
echo "════════════════════════════════════════════════"
echo "  Service Status: sudo systemctl status odoo17  "
echo "════════════════════════════════════════════════"
echo ""
