# Nexus Learning Resource Center
# PHP 8.2 + Apache image for Render and other Docker hosts.
FROM php:8.2-apache

# PDO MySQL is required by app/database.php. mod_rewrite is required by public/.htaccess.
# Python + pypdf are required by the study assistant worker.
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-pip \
    && python3 -m pip install --break-system-packages --no-cache-dir pypdf \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo pdo_mysql \
    && a2enmod rewrite

# The application keeps its public entry point in /public, while the PHP source,
# SQL files and private runtime storage stay outside the web document root.
COPY . /var/www/html/

RUN sed -ri 's!/var/www/html!/var/www/html/public!g' \
        /etc/apache2/sites-available/000-default.conf \
        /etc/apache2/apache2.conf \
    && printf '<Directory /var/www/html/public>\n    AllowOverride All\n    Require all granted\n</Directory>\n' \
        > /etc/apache2/conf-available/nexus-public.conf \
    && a2enconf nexus-public \
    && chown -R www-data:www-data /var/www/html

EXPOSE 80

ENV NEXUS_PYTHON=python3

CMD ["sh", "/var/www/html/scripts/docker-start.sh"]
