#!/bin/sh


checkerr()
{
if test $? -ne 0 ; then
echo error, something is wrong/ has failed!
echo failed step was :
echo "$@"
echo exiting ..
exit 1
fi
}


if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


echo "###################################################"
echo "####### Please provide your new domain name #######"
read -r mys

echo 'server {

        root /var/www/html;
        index index.php index.html index.htm index.nginx-debian.html;

        server_name _;
        gzip on;
        location / {
                try_files $uri $uri/ =404;
        }

location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/run/php/php7.0-fpm.sock;
        }


}' > tmp

mv tmp /etc/nginx/sites-available/$mys

ln -sf /etc/nginx/sites-available/$mys /etc/nginx/sites-enabled/$mys
mkdir -p /var/www/$mys
checkerr mkdir -p /var/www/$mys
sed -i "s/\/var\/www\/html/\/var\/www\/$mys/g"  /etc/nginx/sites-available/$mys
sed -i "s/server_name\ _/server_name\ $mys www.$mys/g"  /etc/nginx/sites-available/$mys
#sed -i "s/server_name\ _/server_name\ www.$mys/g"  /etc/nginx/sites-available/$mys
systemctl reload nginx
checkerr

certbot --nginx -d "$mys" -d "www.$mys" --register-unsafely-without-email --agree-tos -n # can use -m for email
checkerr certbot --nginx -d "$mys" -d "www.$mys" --register-unsafely-without-email --agree-tos -n
nginx -t
checkerr

systemctl reload nginx
checkerr


#chown -R ftpman:www-data /var/www/
#cp -var /var/www/html/phpmyadmin /var/www/$mys/
cd /var/www/$mys/
wget https://files.phpmyadmin.net/phpMyAdmin/4.7.5/phpMyAdmin-4.7.5-all-languages.tar.gz
tar -xzf phpMyAdmin-4.7.5-all-languages.tar.gz
rm -rf phpMyAdmin-4.7.5-all-languages.tar.gz
mv phpMyAdmin-4.7.5-all-languages/ phpmyadmin
cp /var/www/html/index.nginx-debian.html /var/www/$mys/
chown -R ftpman:www-data /var/www/

echo "###################################################"
echo "CONGRATULATIONS ! INSTALLATION IS READY, YOU MAY LOGIN TO SFTP SERVICE"
echo "###################################################"
