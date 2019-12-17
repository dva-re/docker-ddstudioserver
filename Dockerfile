FROM debian:stretch-slim
MAINTAINER fastsol

ADD files/* /root/
EXPOSE 80 22
RUN \
 apt-get update && apt-get install -y --allow-unauthenticated --no-install-recommends wget ca-certificates apt-transport-https gnupg && \
 wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - && \
 echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list && \ 
 apt-get update && apt-get install -y --allow-unauthenticated --no-install-recommends locales openssl openssh-server php php-curl php-apcu php-mbstring php-imagick php-bcmath php-soap pbzip2 unzip ghostscript \
 apache2 php-xml php-gd libzip4 php-zip lsb-release gnupg git nano sphinxsearch cron && \
 a2enmod rewrite && cat /root/vhost_config > /etc/apache2/sites-available/000-default.conf && rm -f /root/vhost_config &&\
 cd /tmp && wget --no-check-certificate https://dev.mysql.com/get/mysql-apt-config_0.8.8-1_all.deb && export DEBIAN_FRONTEND=noninteractive && \
 echo mysql-apt-config mysql-apt-config/enable-repo select mysql-5.7 | debconf-set-selections && dpkg -i mysql-apt-config_0.8.8-1_all.deb && \
 apt-get update && apt-get install -y --allow-unauthenticated --no-install-recommends mysql-server php-mysql && rm -f mysql-apt-config_0.8.8-1_all.deb && \
 cat /root/sshd_config > /etc/ssh/sshd_config && rm -f /root/sshd_config && \
 rm -rf /var/www/html/* && apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && \
 rm -rf /var/cache/debconf/*-old && rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/doc/* && \
 echo 'START=yes' > /etc/default/sphinxsearch && mv /etc/sphinxsearch /etc/sphinxsearch.orig && \
 echo '0 * * * * /usr/bin/indexer --rotate --all' | crontab - && \
 echo -e 'LANG="ru_RU.UTF-8"\nLANGUAGE="ru_RU.UTF-8"\n' > /etc/default/locale && sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
 dpkg-reconfigure --frontend=noninteractive locales && ln -snf /usr/share/zoneinfo/Europe/Moscow /etc/localtime && echo "Europe/Moscow" > /etc/timezone && \
 chmod +x /root/start.sh

VOLUME ["/data", "/var/www/html", "/etc/sphinxsearch"]
CMD ["/root/start.sh"]
