FROM bprodoehl/nginx

#RUN apt-get update && apt-get install -y rsync && rm -r /var/lib/apt/lists/*

#RUN a2enmod rewrite

# install the PHP extensions we need
#RUN apt-get update && apt-get install -y libpng12-dev && rm -rf /var/lib/apt/lists/* \
#	&& docker-php-ext-install gd \
#	&& apt-get purge --auto-remove -y libpng12-dev
#RUN docker-php-ext-install mysqli

# Basic Requirements
RUN apt-get update && \
    apt-get -y install rsync mysql-client nginx php5-fpm php5-mysql \
                       php-apc pwgen python-setuptools curl git unzip

# Wordpress Requirements
RUN apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imagick \
                       php5-imap php5-mcrypt php5-memcache php5-ming php5-ps \
					   php5-pspell php5-recode php5-sqlite php5-tidy \
					   php5-xmlrpc php5-xsl

VOLUME /usr/share/nginx/www

ENV WORDPRESS_VERSION 4.1.0
ENV WORDPRESS_UPSTREAM_VERSION 4.1
ENV WORDPRESS_SHA1 f0437c96ae3d8acaba3579566f1346f4cd06468e

# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_UPSTREAM_VERSION}.tar.gz \
	&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
	&& tar -xzf wordpress.tar.gz -C /usr/src/ \
	&& rm wordpress.tar.gz

RUN curl -O `curl -i -s https://wordpress.org/plugins/nginx-helper/ | egrep -o "https://downloads.wordpress.org/plugin/[^']+"` \
    && unzip -o nginx-helper.*.zip -d /usr/src/wordpress/wp-content/plugins

# nginx site conf
ADD ./nginx-site.conf /etc/nginx/sites-available/default

# install scripts that run once at container start
ADD scripts/setup-db.sh                     /etc/my_init.d/10-setup-db.sh
ADD scripts/activate-nginx-helper-plugin.sh /etc/my_init.d/20-activate-nginx-helper-plugin.sh
