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
apt-get update 
apt dist-upgrade
apt autoremove -y
apt-get install default-jdk -y
apt-get install software-properties-common -y
add-apt-repository ppa:linuxuprising/java -y
add-apt-repository ppa:ondrej/php -y
add-apt-repository ppa:phpmyadmin/ppa -y
add-apt-repository ppa:deadsnakes/ppa -y
add-apt-repository ppa:redislabs/redis -y
add-apt-repository ppa:fkrull/deadsnakes -y
#
apt update
apt-get update 
#
echo "=========================================="
echo " install some tools to help you more :) "
echo "=========================================="
sleep 3
apt-get install -y screen nano curl git zip unzip ufw certbot 
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
apt-get install -y python3.11 libmysqlclient-dev python3-dev python3-pip 
ln -s /usr/bin/python3.11 /usr/bin/python
python3 get-pip.py
python3 -m pip install Django
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
apt -y install php8.1 php8.1-curl php8.1-common php8.1-cli php8.1-mysql php8.1-sqlite3 php8.1-intl php8.1-gd php8.1-mbstring php8.1-fpm php8.1-xml php8.1-zip php8.1-bcmath php8.1-sqlite3 php8.1-gd php8.1-intl php8.1-xmlrpc php8.1-soap php8.1-bz2 php8.1-imagick php8.1-tidy tar redis-server sed composer
systemctl reload nginx
#
echo "=================================="
echo "  Install and Secure phpMyAdmin"
echo "=================================="
sleep 3
apt-get install -y phpmyadmin
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
apt-get update 
#
echo "=================================="
echo "      Installing nodeJS"
echo "=================================="
sleep 3
apt-get install -y gcc g++ make nodejs npm 
#
apt update -y && apt upgrade -y
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
a2enmod php8.1
update-alternatives --set php /usr/bin/php8.1
systemctl reload nginx
#
wget https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/sdomain.sh
chmod +x sdomain.sh
#
apt update
apt-get update 
clear
#
echo "========================================="
DISTRO=`cat /etc/*-release | grep "^ID=" | grep -E -o "[a-z]\w+"`
echo "Your operating system is $DISTRO"
echo "========================================="
CURRENT=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")
echo "current php version of this system PHP-$CURRENT"
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
