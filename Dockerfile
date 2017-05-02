FROM php:7.0-fpm

MAINTAINER Alain Hippolyte <alain.hippolyte@gmail.com>

# Environment variable
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-phpdbg
ENV APCU_VERSION 5.1.5
ENV APCU_BC_VERSION 1.0.3

# Dependencies
RUN apt-get update \
    && apt-get install -y \
        libpq-dev \
        libicu-dev \
        zlib1g-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng12-dev \
        libmcrypt-dev \
        libldap2-dev \
        git \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install intl mbstring pgsql pdo_pgsql pdo_mysql zip gd exif mcrypt ldap \
    && curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin \
    && apt-get autoclean && apt-get clean \
    && rm -r /var/lib/apt/lists/* /tmp/*

# APC
RUN git clone --depth 1 -b v$APCU_VERSION https://github.com/krakjoe/apcu.git /usr/src/php/ext/apcu \
    && git clone --depth 1 -b v$APCU_BC_VERSION https://github.com/krakjoe/apcu-bc.git /usr/src/php/ext/apcu_bc \
    && docker-php-ext-configure apcu \
    && docker-php-ext-configure apcu_bc \
    && docker-php-ext-install opcache apcu apcu_bc \
    && mv /usr/local/etc/php/conf.d/docker-php-ext-apc.ini /usr/local/etc/php/conf.d/zz-docker-php-ext-apc.ini \
    && rm -rf /usr/src/php/ext/apcu \
    && rm -rf /usr/src/php/ext/apcu_bc \
    && rm -rf /tmp/* /var/tmp/*

ENV COMPOSER_ALLOW_SUPERUSER 1

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin \
    && composer global require hirak/prestissimo --prefer-dist --no-progress --no-suggest --optimize-autoloader --classmap-authoritative \
    && composer clear-cache
