#!/bin/bash

# Function to display errors
display_error() {
    echo "Error: $1"
    exit 1
}

echo ""
echo "******************************************"
echo "*        Scar Naruto Add Domain          *"
echo "******************************************"
echo "*    Add New Domain To Server            *"
echo "*     with Lets Encrypt                  *"
echo "******************************************"
echo ""

# Prompt user for domain and email
read -p 'Set Web Domain (Example: 127.0.0.1 [Not trailing slash!]): ' domain
read -p 'Email for Lets Encrypt SSL: ' email
read -p 'Enter PHPMyAdmin Username: ' phpmyadmin_user

# Generate random password for phpMyAdmin
phpmyadmin_password=$(openssl rand -base64 12)

# Validate domain format
if [[ ! $domain =~ ^[a-zA-Z0-9.-]+$ ]]; then
    display_error "Invalid domain format"
fi

# Validate email format
if [[ ! $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    display_error "Invalid email format"
fi

# Validate phpMyAdmin username format
if [[ ! $phpmyadmin_user =~ ^[a-zA-Z0-9._-]+$ ]]; then
    display_error "Invalid phpMyAdmin username format"
fi

mkdir /var/www/html/$domain || display_error "Failed to create directory for domain"
chown -R $USER:$USER /var/www/html/$domain || display_error "Failed to set ownership for domain directory"

# Download Nginx virtual host configuration template
wget -P /etc/nginx/sites-available https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/Example.conf || display_error "Failed to download Nginx virtual host template"
mv /etc/nginx/sites-available/Example.conf /etc/nginx/sites-available/$domain.conf || display_error "Failed to rename Nginx virtual host template"

# Replace placeholder with domain in Nginx virtual host configuration
sed -i "s/example.com/$domain/g" /etc/nginx/sites-available/$domain.conf || display_error "Failed to replace domain in Nginx virtual host configuration"

# Download index.php template
wget -P /var/www/html/$domain https://raw.githubusercontent.com/abdomuftah/LEMP-Plus/main/assets/index.php || display_error "Failed to download index.php template"
sed -i "s/example.com/$domain/g" /var/www/html/$domain/index.php || display_error "Failed to replace domain in index.php template"

# Create symbolic link for phpMyAdmin
ln -s /usr/share/phpmyadmin /var/www/html/$domain/phpmyadmin || display_error "Failed to create symbolic link for phpMyAdmin"

# Enable Nginx virtual host
ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/ || display_error "Failed to enable Nginx virtual host"

# Reload Nginx
systemctl reload nginx || display_error "Failed to reload Nginx"

# Install Lets Encrypt SSL certificate
certbot --noninteractive --agree-tos --no-eff-email --cert-name $domain --nginx --redirect -d $domain -m $email || display_error "Failed to install Lets Encrypt SSL certificate"

# Renew Lets Encrypt SSL certificate
certbot renew --dry-run || display_error "Failed to renew Lets Encrypt SSL certificate"

# Reload PHP-FPM
service php8.1-fpm reload || display_error "Failed to reload PHP-FPM"

# Display success message
clear
echo "##################################"
echo "You Can Thank Me On :) "
echo "https://twitter.com/Scar_Naruto"
echo "Join My Discord Server "
echo "https://discord.snyt.xyz"
echo "##################################"
echo " Your Domain is now ready  : "
echo "https://$domain"
echo "PHPMyAdmin URL: https://$domain/phpmyadmin"
echo "PHPMyAdmin Username: $phpmyadmin_user"
echo "PHPMyAdmin Password: $phpmyadmin_password"
echo "##################################"

exit
