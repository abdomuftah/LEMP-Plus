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

# Prompt user for domain and email
read -p 'Set Web Domain (Example: example.com): ' domain
read -p 'Email for Lets Encrypt SSL: ' email
read -sp 'Enter MySQL root password:  ' mysql_root_password
echo

# Update system packages
apt update
apt upgrade -y
apt dist-upgrade -y
apt autoremove -y

# Install required packages and repositories
apt-get install default-jdk software-properties-common -y
add-apt-repository ppa:ondrej/php -y
add-apt-repository ppa:phpmyadmin/ppa -y
add-apt-repository ppa:deadsnakes/ppa -y
add-apt-repository ppa:redislabs/redis -y
apt update
apt upgrade -y
# Install additional tools
echo "=========================================="
echo " Installing additional tools..."
echo "=========================================="
sleep 3
apt-get install -y screen nano curl git zip unzip ufw certbot python3-certbot-nginx 
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
apt-get install -y python3.11 libmysqlclient-dev python3-dev python3-pip 
ln -s /usr/bin/python3.11 /usr/bin/python
python3 get-pip.py
python3 -m pip install Django
rm get-pip.py

# Install nginx
echo "=========================================="
echo " Installing nginx..."
echo "=========================================="
sleep 3
apt install nginx -y
systemctl enable --now nginx

# Configure firewall
ufw allow 'Nginx Full'
ufw allow OpenSSH

# Install MySQL
echo "=========================================="
echo " Installing MySQL..."
echo "=========================================="
sleep 3
apt-get -y install mariadb-server mariadb-client
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
sudo systemctl restart mariadb
# Display success message
echo "MariaDB has been successfully installed and secured."
sleep 3
systemctl restart mariadb.service

# Install PHP 8.1 and required modules
echo "=========================================="
echo " Installing PHP 8.1 + modules..."
echo "=========================================="
sleep 3
apt -y install php8.1 php8.1-{curl,common,cli,mysql,sqlite3,intl,gd,mbstring,fpm,xml,redis,zip,bcmath,simplexml,tokenizer,dom,fileinfo,iconv,ctype,xmlrpc,soap,bz2,imagick,tidy}
systemctl enable --now php8.1-fpm

# Install phpMyAdmin
echo "=========================================="
echo " Installing phpMyAdmin..."
echo "=========================================="
sleep 3
apt install -y phpmyadmin 
# Create symbolic link for phpMyAdmin in Nginx web root
ln -s /usr/share/phpmyadmin /var/www/html/$domain/phpmyadmin

# Set MySQL root password in phpMyAdmin configuration
mysql -u root -p"$mysql_root_password" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$mysql_root_password'; FLUSH PRIVILEGES;"
systemctl reload nginx

echo "phpMyAdmin has been installed and configured successfully."
sleep 3
# Update PHP configuration
echo "=========================================="
echo " Updating PHP configuration..."
echo "=========================================="
sleep 3
wget https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/php.ini
cp -f php.ini /etc/php/8.1/cli/
mv -f php.ini /etc/php/8.1/fpm/
systemctl reload nginx
service php8.1-fpm reload

# Create Nginx virtual host
echo "=========================================="
echo " Configuring Nginx virtual host..."
echo "=========================================="
sleep 3
mkdir /var/www/html/$domain
chown -R $USER:$USER /var/www/html/$domain
wget -P /etc/nginx/sites-available https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/Example
mv /etc/nginx/sites-available/Example /etc/nginx/sites-available/$domain
sed -i "s/example.com/$domain/g" /etc/nginx/sites-available/$domain
rm /etc/nginx/sites-available/default
wget -P /var/www/html/$domain https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/index.php
ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/ 
rm /var/www/html/index.nginx-debian.html 
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
certbot --noninteractive --agree-tos --no-eff-email --cert-name $domain --nginx --redirect -d $domain -m $email
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
./glances.sh
wget -P /etc/systemd/system/ https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/glances.service
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
apt update
apt upgrade -y
clear
echo "========================================="
DISTRO=`cat /etc/*-release | grep "^ID=" | grep -E -o "[a-z]\w+"`
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
echo "##################################"
echo "to cheack your server status go to : "
echo " http://$domain:61208  "
#
exit

