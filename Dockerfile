FROM php:5.6-fpm
MAINTAINER Damien PIQUET <dpiquet@teicee.com>

ARG PHP_APCU_VERSION=4.0.11
ARG PHP_XDEBUG_VERSION=2.4.1

RUN apt-get update \
    && apt-get install -y \
        libicu-dev \
        zlib1g-dev \
        postgresql-server-dev-all \
        #php5-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpng-dev \
        libxml2-dev \
        locales-all \
    && docker-php-source extract \
    && curl -L -o /tmp/xdebug-$PHP_XDEBUG_VERSION.tgz http://xdebug.org/files/xdebug-$PHP_XDEBUG_VERSION.tgz \
    && tar xfz /tmp/xdebug-$PHP_XDEBUG_VERSION.tgz \
    && rm -r \
        /tmp/xdebug-$PHP_XDEBUG_VERSION.tgz \
    && mv xdebug-$PHP_XDEBUG_VERSION /usr/src/php/ext/xdebug \
    && docker-php-ext-install \
        intl \
        mbstring \
        mysqli \
#        xdebug \
        zip \
        pdo \
        pdo_pgsql \
        pgsql \
        bcmath \
        mcrypt \
        gettext \
        gd \
        soap \
    && pear install HTML_Common \
    && pear install HTML_QuickForm \
    && pear install Config \
    && pear install channel://pear.php.net/OLE-1.0.0RC2 \
    && pecl install memcached-2.2.0 \
    && docker-php-ext-enable memcached \
    && pecl install memcache \
    && docker-php-ext-enable memcache \
    && docker-php-source delete \
    && php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer \
    && curl -L -o /usr/bin/phpunit https://phar.phpunit.de/phpunit-5.7.phar \
    && chmod +x /usr/bin/phpunit \
    && /usr/bin/phpunit --version \
    && apt-get clean \
    # Change timezone
    && echo "Europe/Paris" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata
