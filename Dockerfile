FROM php:7.3-fpm

RUN echo "en_US UTF-8" >> /etc/locale.gen && \
    echo "ru_RU UTF-8" >> /etc/locale.gen && \
    echo "uk_UA UTF-8" >> /etc/locale.gen && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "uk_UA.UTF-8 UTF-8" >> /etc/locale.gen && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
        locales \
        gettext \
        libzip-dev \
        zlib1g-dev \
        jpegoptim \
        optipng \
        pngquant \
        gifsicle \
        libmagickwand-dev \
        imagemagick && \
    locale-gen && \
    pecl install imagick && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install \
        gettext \
        zip \
        gd \
        pdo_mysql && \
    docker-php-ext-enable \
        opcache.so \
        imagick && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

COPY php.ini /usr/local/etc/php/conf.d/custom.ini
