FROM php:7.4-fpm
MAINTAINER Aleksey Ilyin <alksily@outlook.com>

# Set vars
ENV PLATFORM_HOME="/var/container"

# Install packages, install php modules
RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        wget \
        gnupg2 \
    && echo "deb-src http://nginx.org/packages/debian buster nginx" | tee /etc/apt/sources.list.d/nginx.list \
    && wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key && rm nginx_signing.key \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        nginx \
        git \
        unzip \
        supervisor \
        libmcrypt-dev \
        libzip-dev \
        libpng-dev \
        libyaml-dev \
        libonig-dev \
        zlib1g-dev \
    && nginx -V \
    && pecl install yaml \
    && docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) zip gd pdo_mysql mbstring \
    && docker-php-ext-enable opcache.so yaml \
    && docker-php-source delete \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --quiet --install-dir=/usr/bin --filename=composer \
    && rm composer-setup.php

# Copy configs
COPY php.ini /usr/local/etc/php/conf.d/custom.ini
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY entrypoint.sh /entrypoint.sh

# Set homedir as work
WORKDIR ${PLATFORM_HOME}

# Final step
RUN set -x \
    && chmod 755 /entrypoint.sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm /var/log/lastlog /var/log/faillog \
    && chmod -R 0777 ${PLATFORM_HOME}

EXPOSE 80/tcp 443/tcp

STOPSIGNAL SIGTERM

CMD ["/entrypoint.sh"]
