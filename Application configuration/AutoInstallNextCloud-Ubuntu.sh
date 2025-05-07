#!/bin/bash

# Ask for IP (default: localhost)
read -p "Enter the server IP (default: localhost): " SERVER_IP
SERVER_IP=${SERVER_IP:-localhost}
echo "Using server IP: $SERVER_IP"
echo ""

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

# Updating system
start_progress 2 "Updating system"
sudo apt update -y > /dev/null 2>&1
update_progress
sudo apt upgrade -y > /dev/null 2>&1
update_progress

# Installing required packages
start_progress 1 "Installing packages (Apache, PHP, MySQL...)"
sudo apt install unzip apache2 mysql-server php8.3 libapache2-mod-php php8.3-common php8.3-cli php8.3-mbstring php8.3-bcmath php8.3-fpm php8.3-mysql php8.3-zip php8.3-gd php8.3-curl php8.3-xml -y > /dev/null 2>&1
update_progress

# Configuring Apache
start_progress 2 "Configuring Apache"
sudo systemctl start apache2 > /dev/null 2>&1
update_progress
sudo systemctl enable apache2 > /dev/null 2>&1
update_progress

# Configuring MySQL
start_progress 3 "Configuring MySQL"
sudo systemctl start mysql > /dev/null 2>&1
update_progress
sudo systemctl enable mysql > /dev/null 2>&1
update_progress
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; FLUSH PRIVILEGES;" > /dev/null 2>&1
update_progress

# Creating DB and user
start_progress 1 "Creating Nextcloud database"
sudo mysql -uroot -proot > /dev/null 2>&1 <<EOF
CREATE DATABASE nextclouddb;
CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'nextcloud';
GRANT ALL ON nextclouddb.* TO 'nextcloud'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
update_progress

# Download and configure Nextcloud
start_progress 4 "Setting up Nextcloud"
cd /tmp
update_progress
wget -q https://download.nextcloud.com/server/releases/nextcloud-28.0.3.zip
update_progress
unzip -q nextcloud-28.0.3.zip
update_progress
sudo mv nextcloud /var/www/html/ && sudo chown -R www-data:www-data /var/www/html/nextcloud
update_progress

# Apache virtual host
start_progress 6 "Configuring Apache virtual host"
sudo bash -c "cat > /etc/apache2/sites-available/nextcloud.conf" <<EOL
<VirtualHost *:80>
    DocumentRoot "/var/www/html/nextcloud"
    ServerName $SERVER_IP
    ErrorLog \${APACHE_LOG_DIR}/nextcloud.error
    CustomLog \${APACHE_LOG_DIR}/nextcloud.access combined
    <Directory /var/www/html/nextcloud/>
        Require all granted
        Options FollowSymlinks MultiViews
        AllowOverride All
    </Directory>
</VirtualHost>
EOL
update_progress
echo "ServerName $SERVER_IP" | sudo tee -a /etc/apache2/apache2.conf > /dev/null
update_progress
sudo a2ensite nextcloud.conf > /dev/null 2>&1
update_progress
sudo systemctl reload apache2 > /dev/null 2>&1
update_progress
sudo apachectl -t > /dev/null 2>&1
update_progress
sudo systemctl restart apache2 > /dev/null 2>&1
update_progress

echo ""
echo "Nextcloud installation complete!"
# Display access information
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                 NEXTCLOUD SETUP INFORMATION            ║"
echo "╠════════════════════════════════════════════════════════╣"
echo "║  Access URL:     http://$SERVER_IP/nextcloud/index.php ║"
echo "║  Install path:   /var/www/html/nextcloud               ║"
echo "╠════════════════════════════════════════════════════════╣"
echo "║  Database Credentials:                                 ║"
echo "║  ▪ Username:     nextcloud                             ║"
echo "║  ▪ Password:     nextcloud                             ║"
echo "║  ▪ Database:     nextclouddb                           ║"
echo "╠════════════════════════════════════════════════════════╣"
echo "║  Admin account:  (set during first access)             ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

