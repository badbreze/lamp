FROM ubuntu:xenial
MAINTAINER Fernando Mayo <fernando@tutum.co>, Feng Honglin <hfeng@tutum.co>, Martin Di Palma <tincho.dipalma@gmail.com>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install supervisor \
    python-software-properties \
    software-properties-common \
    build-essential \
    libssl-dev \
    openssl \
    curl \
    ruby \
    git \
    vim \
    zip \
    nano \
    unzip \
    apache2 \
    pwgen \
    mariadb-server \
    libapache2-mod-php7.0 \
    php7.0 \
    php7.0-cli \
    php7.0-mysql \
    php7.0-curl \
    php7.0-json \
    php7.0-xml \
    php7.0-tidy \
    php7.0-intl \
    php7.0-bz2 \
    php7.0-mbstring \
    php-apcu \
    php-pear \
    php7.0-mcrypt && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN git clone https://github.com/fermayo/hello-world-lamp.git /app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

EXPOSE 80 443 3306
CMD ["/run.sh"]
