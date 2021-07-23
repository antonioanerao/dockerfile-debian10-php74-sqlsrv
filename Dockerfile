FROM debian

ENV APACHE_LOCK_DIR="/var/lock"
ENV APACHE_PID_FILE="/var/run/apache2.pid"
ENV APACHE_RUN_USER="www-data"
ENV APACHE_RUN_GROUP="www-data"
ENV APACHE_LOG_DIR="/var/log/apache2"

LABEL app="Debian 10 para Laravel e SQL Server"
LABEL description="Imagem Docker com Debian 10, Apache2, PHP7.4 e drivers SQL Server"
LABEL version="1.0.0"

RUN apt update \
   && DEBIAN_FRONTEND=noninteractive apt install -y apt-utils sudo curl gnupg vim zip unzip \
   nano wget git lsb-release apt-transport-https ca-certificates 
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
   && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list 
RUN apt update 
RUN apt install -y php7.4 && apt install -y php7.4-sqlite3 php7.4-bcmath php7.4-bz2 php7.1-intl php7.4-gd \
    && apt install -y php7.4-mbstring php7.4-mysql php7.4-zip php7.4-mbstring \
    && apt install -y php7.4-xml php7.4-dev
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17 && ACCEPT_EULA=Y apt-get install  mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN apt install -y unixodbc-dev
RUN pecl install sqlsrv && pecl install pdo_sqlsrv \
    && printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.4/mods-available/sqlsrv.ini \
    && printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.4/mods-available/pdo_sqlsrv.ini
RUN phpenmod -v 7.4 sqlsrv pdo_sqlsrv && service apache2 restart
RUN curl -s https://getcomposer.org/installer | php && mv composer.phar /usr/bin/composer
RUN chown www-data:www-data /var/lock && chown www-data:www-data /var/run && chown www-data:www-data /var/log \
    && chown www-data:www-data /var/log/apache2/error.log && chown www-data:www-data -R /var/www
RUN echo "<VirtualHost *:80> \n\
	ServerAdmin webmaster@localhost \n\
	DocumentRoot /var/www/html \n\
	<Directory /var/www/html> \n\
	    AllowOverride All \n\
            Require all granted \n\
       </Directory> \n\
	ErrorLog ${APACHE_LOG_DIR}/error.log \n\
	CustomLog ${APACHE_LOG_DIR}/access.log combined \n\
</VirtualHost>" > /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

VOLUME /var/www
WORKDIR /var/www
EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
