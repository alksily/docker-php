FROM php:7.0-fpm-jessie
MAINTAINER Aleksey Ilyin <alksily@outlook.com>

# Set vars
ENV PLATFORM_HOME="/var/container"

# Install packages, install php modules
RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        wget \
        gnupg2 \
        libcurl3-gnutls \
        apt-transport-https \
    && echo "deb-src http://nginx.org/packages/debian jessie nginx" | tee /etc/apt/sources.list.d/nginx.list \
    && wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key && rm nginx_signing.key \
    && curl http://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl http://packages.microsoft.com/config/debian/8/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install --no-install-recommends -y \
        openssl \
        ca-certificates \
        locales \
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
        msodbcsql \
        unixodbc-dev \
    && nginx -V \
    && pecl install -f yaml-2.0.0 sqlsrv-4.1.6 pdo_sqlsrv-4.1.6 \
    && docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) zip gd pdo_mysql mbstring \
    && docker-php-ext-enable opcache.so sqlsrv pdo_sqlsrv yaml \
    && docker-php-source delete \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --quiet --install-dir=/usr/bin --filename=composer \
    && rm composer-setup.php

# Set locales
RUN echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "be_BY.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "uk_UA.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

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
