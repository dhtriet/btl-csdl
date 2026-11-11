# PHP/Apache runtime for Render. The public directory is the only web root.
FROM php:8.2-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-pip \
    && python3 -m pip install --break-system-packages --no-cache-dir pypdf \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo pdo_mysql \
    && a2enmod rewrite

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
