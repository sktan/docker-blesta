FROM amazonlinux:2

# Install PHP requirements: https://docs.blesta.com/display/user/Requirements
RUN amazon-linux-extras enable php7.3 epel && yum clean metadata && \
    yum install -y epel-release && \
    yum install -y supervisor nginx curl unzip zip php php-fpm \
    php-pdo php-mysqlnd php-common php-gmp \
    php-json php-mbstring php-ldap && \
    # Setup www-data user for the website
    useradd -r -s /bin/false www-data && usermod -a -G www-data www-data

# Install Ioncube and download Blesta
RUN curl -o /tmp/ioncube.zip https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.zip && \
    mkdir -p /tmp/ioncube && unzip /tmp/ioncube.zip -d /usr/lib64/php/modules && \
    echo "zend_extension=ioncube/ioncube_loader_lin_7.3.so" > /etc/php.d/10-php-ioncube.ini && \
    curl -o /tmp/blesta.zip https://account.blesta.com/client/plugin/download_manager/client_main/download/143/blesta-4.8.1.zip

# Setup website folder structure
RUN mkdir -p /var/www/html && mkdir -p /run/php && \
    # Install Blesta
    unzip -qq /tmp/blesta.zip -d /var/www/html && \
    cp -rf /var/www/html/hotfix-php71/blesta/ /var/www/html/blesta && \
    chown www-data:www-data -R /var/www/html && \
    find /var/www/html -type d -exec chmod 750 {} \; && \
    find /var/www/html -type f -exec chmod 640 {} \;

# Add PHP and NGINX configurations
ADD configs /

# Generate snake-oil SSL certificate for a year for reverse proxy purposes
RUN openssl req -subj "/C=AU/ST=NSW/L=Sydney/O=Nginx Web/OU=Proxy/CN=localhost" -new -newkey rsa:2048 -days 730 -nodes -x509 -sha256 -keyout /etc/nginx/localhost.key -out /etc/nginx/localhost.crt

EXPOSE 443

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
