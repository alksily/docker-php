FROM php:7.3-fpm
RUN apt-get -qq update -y && \
    apt-get -qq install --no-install-recommends -y \
        libzip-dev \
        zlib1g-dev \
        jpegoptim \
        optipng \
        pngquant \
        gifsicle \
        libmagickwand-dev \
        imagemagick && \
    echo '' | pecl install imagick && \
    docker-php-ext-install zip && \
    docker-php-ext-enable opcache.so && \
    docker-php-ext-enable imagick && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

COPY php.ini /usr/local/etc/php/conf.d/custom.ini
RUN usermod -u 1000 www-data
USER www-data
WORKDIR /var/container
