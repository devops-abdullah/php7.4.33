FROM php:7.4.33-apache-buster

COPY httpd.conf /etc/apache2/conf-available/
COPY ioncube_loader_lin_7.4.so /usr/lib/
COPY php.ini /usr/local/etc/php/
COPY ports.conf /etc/apache2/
COPY 000-default.conf /etc/apache2/sites-available/
RUN mkdir -p /etc/ssl/private
COPY server* /etc/ssl/private/

RUN pecl install mongodb \
    && apt-get update \
    && apt-get install git wget net-tools telnet curl -y \
    && useradd apache

RUN a2enmod rewrite \
    && a2enmod socache_shmcb \
    && a2enmod ssl \
    && ln -s /etc/apache2/conf-available/httpd.conf /etc/apache2/conf-enabled/

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-install mysqli pdo_mysql gettext zip

WORKDIR /var/www/html
COPY htaccess .htaccess

LABEL php.extensions1="gd" \
      php.extensions2="Mysqli" \
      php.extensions3="PDO_Mysql" \
      php.extensions4="Gettext" \
      php.extensions5="ZIP" \
      php.extensions6="LZIP" \
      php.extensions7="Mongo"

EXPOSE 8080/tcp
