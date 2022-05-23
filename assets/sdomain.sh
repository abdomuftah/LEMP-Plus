#!/bin/bash
#
echo ""
echo "******************************************"
echo "*  	  Scar Naruto add Domain		   *"
echo "******************************************"
echo "*       Add New Domain To Server         *"
echo "*          with Let's Encrypt            *"
echo "******************************************"
echo ""
#
read -p 'Set Web Domain (Example: 127.0.0.1 [Not trailing slash!]) : ' sdomain
read -p 'Email for Lets Encrypt SSL : ' semail
#
mkdir /var/www/html/$sdomain
wget -P /etc/nginx/sites-available https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/Example.conf
mv /etc/nginx/sites-available/Example.conf /etc/nginx/sites-available/$sdomain.conf
sed -i "s/example.com/$sdomain/g" /etc/nginx/sites-available/$sdomain.conf
wget -P /var/www/html/$sdomain https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/index.php
a2ensite $sdomain
systemctl restart nginx
certbot --noninteractive --agree-tos --no-eff-email --cert-name $sdomain --nginx --redirect -d $sdomain -m $semail
systemctl restart nginx.service
certbot renew --dry-run
systemctl restart nginx.service
clear
echo "##################################"
echo "You Can Thank Me On :) "
echo "https://twitter.com/Scar_Naruto"
echo "Join My Discord Server "
echo "https://discord.snyt.xyz"
echo "##################################"
echo " ypur Domain is now ready  : "
echo "https://$sdomain 	"
#
exit
