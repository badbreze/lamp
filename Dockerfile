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
    openssh-server \
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
    php7.0-bcmath \
    php7.0-mbstring \
    php-apcu \
    php-pear \
    php7.0-mcrypt && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD start-openssh.sh /start-openssh.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD supervisord-openssh.conf /etc/supervisor/conf.d/supervisord-openssh.conf

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
#ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite
RUN a2enmod vhost_alias

# config to enable dynamic domains
ADD apache_dynamic /etc/apache2/conf-available/apache-dynamic.conf
RUN a2enconf apache-dynamic

# Setting up OpenSSh
RUN mkdir /var/run/sshd
RUN echo "root:rememberme" | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

##Max connections
RUN echo "MaxSessions 30" >> /etc/ssh/sshd_config

# Configure /app folder with sample app
RUN mkdir -p /app && rm -fr /var/www && ln -s /app /var/www

#Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#Install fxp
RUN composer global require "fxp/composer-asset-plugin:^1.2.0"

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 100M
ENV PHP_POST_MAX_SIZE 100M

EXPOSE 22 80 443 3306
CMD ["/run.sh"]
