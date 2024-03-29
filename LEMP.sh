#!/bin/bash
#
clear
echo ""
echo "******************************************"
echo "*   Scar Naruto UBUNTU 18 + Script       *"
echo "******************************************"
echo "*       this script well install         *"
echo "*      LEMP server and phpMyAdmin        *"
echo "*     With node js and secure your       *"
echo "*      Domain with Let's Encrypt         *"
echo "******************************************"
echo ""
#
read -p 'Set Web Domain (Example: 127.0.0.1 [Not trailing slash!]) : ' domain
read -p 'Email for Lets Encrypt SSL : ' email
read -p 'mySql Password  : ' sqpass
#
apt update
apt upgrade -y
apt-get update 
apt-get upgrade -y
apt dist-upgrade
apt autoremove -y
apt-get install default-jdk -y
apt-get install software-properties-common -y
apt-add-repository ppa:webupd8team/java -y
add-apt-repository ppa:ondrej/php -y
add-apt-repository ppa:phpmyadmin/ppa -y
#add-apt-repository ppa:deadsnakes/ppa -y
apt -y install lsb-release apt-transport-https ca-certificates wget -y
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
#
apt update
apt upgrade -y
apt-get update 
apt-get upgrade -y
#
echo "=========================================="
echo " install some tools to help you more :) "
echo "=========================================="
sleep 3
apt-get install -y screen nano curl git zip unzip ufw certbot 
apt-get install -y python3.7 python3-dev python3-pip 
#
echo "=================================="
echo "          installing nginx"
echo "=================================="
sleep 3
apt install nginx -y
#
systemctl stop nginx.service
systemctl start nginx.service
systemctl enable nginx.service
#
ufw app list
ufw allow 'Nginx Full'
ufw allow OpenSSH
#
echo "=================================="
echo "      installing mySQL :"
echo "=================================="
sleep 3
apt-get -y install mariadb-server mariadb-client
#
systemctl stop mariadb.service
systemctl start mariadb.service
systemctl enable mariadb.service
#
mysql_secure_installation
systemctl restart mysql.service
#
echo "=================================="
echo "   installing PHP 8.1 + modules"
echo "=================================="
sleep 3
apt install php8.1 php8.1-curl php8.1-common php8.1-cli php8.1-mysql php8.1-mbstring php8.1-fpm php8.1-xml php8.1-zip php8.1-bcmath php8.1-sqlite3 php8.1-gd php8.1-intl php8.1-exif php8.1-bz2
apt -y install tar sed composer
systemctl reload nginx
#
echo "=================================="
echo "  Install and Secure phpMyAdmin"
echo "=================================="
sleep 3
apt-get install -y phpmyadmin php8.1-gettext
#
echo "=================================="
echo "      Update php.ini file "
echo "=================================="
sleep 3
wget https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/php.ini && cp  -f php.ini /etc/php/8.1/nginx/ && mv -f php.ini /etc/php/8.1/fpm/
#
a2enmod rewrite
systemctl reload nginx
systemctl reload nginx
#
mkdir /var/www/html/$domain
wget -P /etc/nginx/sites-available https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/Example.conf
mv /etc/nginx/sites-available/Example.conf /etc/nginx/sites-available/$domain.conf
sed -i "s/example.com/$domain/g" /etc/nginx/sites-available/$domain.conf
rm /etc/nginx/sites-available/000-default.conf
wget -P /var/www/html/$domain https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/index.php
ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/ 
systemctl reload nginx
service php8.1-fpm reload
#
apt update
apt upgrade -y
apt-get update 
apt-get upgrade -y
#
echo "=================================="
echo "      Installing nodeJS"
echo "=================================="
sleep 3
apt-get install -y gcc g++ make nodejs npm 
#
apt update -y && apt upgrade -y
apt-get update && apt-get upgrade -y
systemctl reload nginx
#
echo "=================================="
echo "    Fixing MySQL And phpMyAdmin"
echo "=================================="
sleep 3
wget https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/fix.sql
mysql -u root < fix.sql 
service mysql restart
systemctl reload nginx
rm fix.sql 
#
echo "=================================="
echo "      Installing Let's Encrypt "
echo "=================================="
sleep 3
certbot --noninteractive --agree-tos --no-eff-email --cert-name $domain --nginx --redirect -d $domain -m $email
systemctl reload nginx
certbot renew --dry-run
systemctl reload nginx
#
echo "=================================="
echo "      Installing glances "
echo "=================================="
sleep 3
wget  https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/glances.sh
chmod +x glances.sh
./glances.sh
wget -P /etc/systemd/system/ https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/glances.service
systemctl start glances.service
systemctl enable glances.service
rm glances.sh
#
add-apt-repository -r ppa:ondrej/php -y
add-apt-repository -r ppa:phpmyadmin/ppa -y
add-apt-repository -r ppa:webupd8team/java -y
add-apt-repository -r ppa:chris-lea/redis-server -y
add-apt-repository -r ppa:deadsnakes/ppa -y
#
wget https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/sdomain.sh
chmod +x sdomain.sh
#
apt update
apt upgrade -y
apt-get update 
apt-get upgrade -y
clear
#
echo "your PHP Ver is :"
php -v 
#
echo "##################################"
echo "You Can Thank Me On :) "
echo "https://twitter.com/Scar_Naruto"
echo "Join My Discord Server "
echo "https://discord.snyt.xyz"
echo "##################################"
echo "you can add new domain to your server  "
echo "by typing : ./domain.sh in the terminal  "
echo "##################################"
echo "to cheack your server status go to : "
echo " http://$domain:61208  "
#
exit
