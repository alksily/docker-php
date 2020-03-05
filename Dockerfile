FROM php:7.3-fpm

# Install software
RUN apt-get update -y && \
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
        imagemagick

# Set locales
RUN echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "be_BY.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "uk_UA.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

# Setting up service
RUN locale-gen && \
    pecl install imagick && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install \
        gettext \
        zip \
        gd \
        pdo_mysql && \
    docker-php-ext-enable \
        opcache.so \
        imagick

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

COPY php.ini /usr/local/etc/php/conf.d/custom.ini
