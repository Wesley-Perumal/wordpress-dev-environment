FROM wordpress

COPY ./ssl.crt /etc/apache2/ssl/ssl.crt
COPY ./ssl.key /etc/apache2/ssl/ssl.key
COPY dev.conf /etc/apache2/sites-enabled/dev.conf
RUN mkdir -p /var/run/apache2/
RUN [ "$WORDPRESS_ENV" = "development" ]; apt-get update &&\
    apt-get install --no-install-recommends --assume-yes --quiet ca-certificates curl git &&\
    rm -rf /var/lib/apt/lists/* &&\
    apt-get clean
RUN [ "$WORDPRESS_ENV" = "development" ]; curl -Lsf 'https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz' | tar -C '/usr/local' -xvzf -
ENV PATH /usr/local/go/bin:$PATH
RUN [ "$WORDPRESS_ENV" = "development" ]; go get github.com/mailhog/mhsendmail
RUN [ "$WORDPRESS_ENV" = "development" ]; cp /root/go/bin/mhsendmail /usr/bin/mhsendmail
RUN [ "$WORDPRESS_ENV" = "development" ]; echo 'sendmail_path = /usr/bin/mhsendmail --smtp-addr mailhog:1025' > /usr/local/etc/php/php.ini

RUN a2enmod rewrite
RUN a2enmod ssl

CMD /usr/sbin/apache2ctl -D FOREGROUND