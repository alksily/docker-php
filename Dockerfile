FROM php:7.3-fpm
RUN apt-get update -y && \
    apt-get install --no-install-recommends -y \
        libzip-dev \
        zlib1g-dev \
        jpegoptim \
        optipng \
        pngquant \
        gifsicle \
        libmagickwand-dev \
        imagemagick && \
    pecl install imagick && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install \
        zip \
        gd \
        pdo_mysql \
        pdo_pgsql \
        pdo_sqlite \
        mbstring && \
    docker-php-ext-enable \
        opcache.so \
        imagick && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

COPY php.ini /usr/local/etc/php/conf.d/custom.ini
