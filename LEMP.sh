#!/bin/bash
#
clear
echo ""
echo "******************************************"
echo "*      Ubuntu 22 LEMP Server Setup       *"
echo "******************************************"
echo "* This script will install a LEMP stack *"
echo "* with phpMyAdmin, Node.js, and secure  *"
echo "* your domain with Let's Encrypt SSL.   *"
echo "******************************************"
echo ""

# Function to display error message and exit
display_error() {
    echo "Error: $1"
    exit 1
}

# Function to prompt user for input and validate
prompt_for_input() {
    read -p "$1" input
    if [[ -z "$input" ]]; then
        display_error "Input cannot be empty"
    fi
    echo "$input"
}

# Prompt user for domain and email
domain=$(prompt_for_input "Set Web Domain (Example: example.com): ")
email=$(prompt_for_input "Email for Let's Encrypt SSL: ")
mysql_root_password=$(prompt_for_input "Enter MySQL root password: ")

# Update system packages
apt update && apt upgrade -y || display_error "Failed to update system packages"
apt autoremove -y

# Install required packages and repositories
apt-get install default-jdk software-properties-common -y || display_error "Failed to install packages"
add-apt-repository ppa:ondrej/php -y
add-apt-repository ppa:ondrej/nginx-mainline -y
add-apt-repository ppa:phpmyadmin/ppa -y
add-apt-repository ppa:deadsnakes/ppa -y
add-apt-repository ppa:redislabs/redis -y
apt update && apt upgrade -y

# Install additional tools
echo "=========================================="
echo " Installing additional tools..."
echo "=========================================="
sleep 3
apt-get install -y screen nano curl git zip unzip ufw certbot python3-certbot-nginx || display_error "Failed to install additional tools"
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
apt-get install -y python3.11 libmysqlclient-dev python3-dev python3-pip
ln -s /usr/bin/python3.11 /usr/bin/python
python3 get-pip.py || display_error "Failed to install Python pip"
python3 -m pip install Django
rm get-pip.py

# Install nginx
echo "=========================================="
echo " Installing nginx..."
echo "=========================================="
sleep 3
apt install nginx -y || display_error "Failed to install nginx"
systemctl enable --now nginx

# Configure firewall
ufw allow 'Nginx Full'
ufw allow OpenSSH

# Install MySQL
echo "=========================================="
echo " Installing MySQL..."
echo "=========================================="
sleep 3
apt-get -y install mariadb-server mariadb-client || display_error "Failed to install MySQL"
# Secure MariaDB installation
sudo mysql_secure_installation <<EOF
Y
$mysql_root_password
$mysql_root_password
Y
Y
Y
Y
EOF

# Restart MariaDB service
sudo systemctl restart mariadb || display_error "Failed to restart MariaDB"
# Display success message
echo "MariaDB has been successfully installed and secured."
sleep 3

# Install PHP 8.1 and required modules
echo "=========================================="
echo " Installing PHP 8.1 + modules..."
echo "=========================================="
sleep 3
apt -y install php8.1 php8.1-{curl,common,cli,mysql,sqlite3,intl,gd,mbstring,fpm,xml,redis,zip,bcmath,simplexml,tokenizer,dom,fileinfo,iconv,ctype,xmlrpc,soap,bz2,imagick,tidy} || display_error "Failed to install PHP"
systemctl enable --now php8.1-fpm

# Install phpMyAdmin
echo "=========================================="
echo " Installing phpMyAdmin..."
echo "=========================================="
sleep 3
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $mysql_root_password" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $mysql_root_password" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
apt-get install -y phpmyadmin || display_error "Failed to install phpMyAdmin"

# Update PHP configuration
echo "=========================================="
echo " Updating PHP configuration..."
echo "=========================================="
sleep 3
wget https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/php.ini || display_error "Failed to download PHP configuration file"
cp -f php.ini /etc/php/8.1/cli/ || display_error "Failed to copy PHP configuration file to CLI directory"
mv -f php.ini /etc/php/8.1/fpm/ || display_error "Failed to move PHP configuration file to FPM directory"
systemctl reload nginx
service php8.1-fpm reload

# Create Nginx virtual host
echo "=========================================="
echo " Configuring Nginx virtual host..."
echo "=========================================="
sleep 3
mkdir /var/www/html/$domain
chown -R $USER:$USER /var/www/html/$domain
# Create symbolic link for phpMyAdmin in Nginx web root
wget -P /var/www/html/$domain https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/index.php || display_error "Failed to download index.php"
ln -s /usr/share/phpmyadmin /var/www/html/$domain/phpmyadmin || display_error "Failed to create symbolic link for phpMyAdmin"
sed -i "s/example.com/$domain/g" /var/www/html/$domain/index.php || display_error "Failed to replace domain in index.php"
rm /var/www/html/index.nginx-debian.html 
wget -P /etc/nginx/sites-available https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/Example.conf || display_error "Failed to download Nginx configuration file"
mv /etc/nginx/sites-available/Example.conf /etc/nginx/sites-available/$domain.conf || display_error "Failed to move Nginx configuration file"
sed -i "s/example.com/$domain/g" /etc/nginx/sites-available/$domain.conf || display_error "Failed to replace domain in Nginx configuration file"
ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/ 
mv /etc/nginx/snippets/fastcgi-php.conf /etc/nginx/snippets/back-fastcgi-php.conf
wget -P /etc/nginx/snippets/ https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/fastcgi-php.conf || display_error "Failed to download FastCGI PHP configuration file"
systemctl start nginx
systemctl reload nginx
service php8.1-fpm reload

# Install Node.js
echo "=========================================="
echo " Installing Node.js..."
echo "=========================================="
sleep 3
apt-get install -y gcc g++ make nodejs npm 
apt update -y && apt upgrade -y
systemctl reload nginx
service php8.1-fpm reload

# Install Let's Encrypt SSL
echo "=========================================="
echo " Installing Let's Encrypt SSL..."
echo "=========================================="
sleep 3
certbot --noninteractive --agree-tos --no-eff-email --cert-name $domain --nginx --redirect -d $domain -m $email || display_error "Failed to install Let's Encrypt SSL"
systemctl reload nginx
certbot renew --dry-run
systemctl reload nginx

# Install glances
echo "=========================================="
echo " Installing glances..."
echo "=========================================="
sleep 3
wget  https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/glances.sh
chmod +x glances.sh
./glances.sh || display_error "Failed to install Glances"
wget -P /etc/systemd/system/ https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/glances.service || display_error "Failed to download Glances service file"
systemctl start glances.service
systemctl enable glances.service
rm glances.sh

# Set PHP version
update-alternatives --set php /usr/bin/php8.1
systemctl reload nginx
service php8.1-fpm reload

# Additional configuration scripts
wget https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/sdomain.sh
chmod +x sdomain.sh

# Final messages
apt update && apt upgrade -y
clear
echo "========================================="
DISTRO=$(cat /etc/*-release | grep "^ID=" | grep -E -o "[a-z]\w+")
echo "Your operating system is $DISTRO"
echo "========================================="
CURRENT=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")
echo "current php version of this system PHP-$CURRENT"
#
echo "##################################"
echo "You Can Thank Me On :) "
echo "https://twitter.com/ScarNaruto"
echo "Join My Discord Server "
echo "https://discord.snyt.xyz"
echo "##################################"
echo "you can add new domain to your server  "
echo "by typing : ./sdomain.sh in the terminal  "
echo "----------------------------------"
echo "phpMyAdmin Credentials:"
echo "Username: root"
echo "Password: $mysql_root_password"
echo "----------------------------------"
echo "Check your webserver by going to this link : "
echo " https://$domain  "
#
rm ~/LEMP.sh
exit
