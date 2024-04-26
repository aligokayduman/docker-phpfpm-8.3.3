FROM php:8.3.3-fpm

MAINTAINER A. Gökay Duman <aligokayduman@gmail.com>

# Allow licenses
ENV ACCEPT_EULA=Y

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

# Update repos
RUN apt-get update

RUN apt install -y \
    apt-utils \
    gnupg \
    apt-transport-https \
    nano \
    zip \
    unzip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install libraries for redis & xdebug
RUN apt install -y \
       libcurl4-openssl-dev \
       libc-client-dev

# Install redis & xdebug extensions
RUN pecl install redis-5.3.7 \
        && docker-php-ext-enable redis
	
RUN pecl install xdebug-3.3.1 \
    && docker-php-ext-enable xdebug		

# Install libraries for gd & imap
RUN apt install -y \
       libfreetype6-dev \
       libpng-dev \
       libgd-dev \
       libkrb5-dev \
       libicu-dev \
       libxml2-dev \
       libxslt-dev \
       libzip-dev \
       libjpeg-dev

# Install gd extension
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Install imap extension
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) imap

# Install laravel requirements
RUN docker-php-ext-install bcmath intl pdo_mysql soap xsl zip opcache sockets

# Clean temp files
RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Start PHP-FPM
CMD ["php-fpm"]
