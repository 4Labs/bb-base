FROM php:5.6-apache

ENV TZ=Europe/Paris

ARG PHP_APCU_VERSION=4.0.11
ARG PHP_XDEBUG_VERSION=2.4.1

# Update sources.list (needed as stretch is deprecated since 2020)
# load memcache pecl deps (not downloadable from  pecl anymore)
COPY . /

       # Prepare empty man directories (necessary when using
       # images based on 'slim' versions of debian)
RUN    bash -c "mkdir /usr/share/man/man{1..9}" \
       # Install required packages
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        sudo \
        imagemagick \
        libicu-dev \
        zlib1g-dev \
        postgresql-server-dev-all \
        #php5-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpng-dev \
        libxml2-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libxpm-dev \
        locales-all \
        man \
        postgresql-client \
        git \
        unzip \
        supervisor \
        cron \
        logrotate \
       # Prepare the xdebug docker php extensions
    && docker-php-source extract \
    && curl -L -o /tmp/xdebug-$PHP_XDEBUG_VERSION.tgz http://xdebug.org/files/xdebug-$PHP_XDEBUG_VERSION.tgz \
    && tar xfz /tmp/xdebug-$PHP_XDEBUG_VERSION.tgz \
    && rm -r \
        /tmp/xdebug-$PHP_XDEBUG_VERSION.tgz \
    && mv xdebug-$PHP_XDEBUG_VERSION /usr/src/php/ext/xdebug \
    # Install docker php extensions
    && docker-php-ext-configure gd --with-gd --with-webp-dir --with-jpeg-dir \
       --with-png-dir --with-zlib-dir --with-xpm-dir --with-freetype-dir \
       --enable-gd-native-ttf \
    && docker-php-ext-install \
        intl \
        mbstring \
        mysqli \
        xdebug \
        zip \
        pdo \
        pdo_pgsql \
        pgsql \
        bcmath \
        mcrypt \
        gettext \
        gd \
        soap \
        sockets \
    && pear install HTML_Common \
    && pear install HTML_QuickForm \
    && pear install Config \
    && pear install channel://pear.php.net/OLE-1.0.0RC2 \
    && pecl install /memcached-2.2.0.tgz \
    && docker-php-ext-enable memcached \
    && pecl install /memcache-2.2.7.tgz \
    && docker-php-ext-enable memcache \
    && docker-php-source delete \
    #
    # Install latest composer 1
    #
    && curl https://getcomposer.org/composer-1.phar > /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && curl -L -o /usr/bin/phpunit https://phar.phpunit.de/phpunit-5.7.phar \
    && chmod +x /usr/bin/phpunit \
    && /usr/bin/phpunit --version \
    && apt-get clean \
       # Change timezone
       # Enable httpd mods
    && a2enmod \
        rewrite \
        proxy \
        deflate \
        mime \
        expires \
        proxy_http

# PHP sessions are store in /tmp
VOLUME /tmp
