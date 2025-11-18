FROM composer:2 AS composer_image

FROM php:8.3-fpm

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DRUPAL_VERSION=11.2.5
ENV DRUPAL_ROOT=/opt/drupal
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_NO_INTERACTION=1

# Install required system dependencies and PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libcurl4-openssl-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    build-essential \
    unzip \
    mariadb-client \
    nginx \
    netcat-traditional \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    curl \
    gd \
    intl \
    mbstring \
    mysqli \
    pdo_mysql \
    opcache \
    zip

# Provide Composer inside the container
COPY --from=composer_image /usr/bin/composer /usr/bin/composer
RUN mkdir -p ${DRUPAL_ROOT} && chown www-data:www-data ${DRUPAL_ROOT}

USER www-data
WORKDIR /tmp

# Create Drupal project using Composer and install Drush dependency
RUN composer create-project drupal/recommended-project:${DRUPAL_VERSION} ${DRUPAL_ROOT} --no-interaction --no-progress
RUN composer --working-dir=${DRUPAL_ROOT} require drush/drush:^13 --no-interaction --no-progress

USER root
WORKDIR ${DRUPAL_ROOT}

# Symlink Drush so it's globally accessible
RUN ln -s ${DRUPAL_ROOT}/vendor/bin/drush /usr/local/bin/drush && drush --version

# Copy challenge flag and privileged reader utility
COPY flag.txt /flag.txt
COPY readflag.c /tmp/readflag.c
RUN gcc /tmp/readflag.c -o /readflag && \
    chown root:root /flag.txt /readflag && \
    chmod 400 /flag.txt && \
    chmod 4755 /readflag && \
    rm /tmp/readflag.c

# Copy custom assets into Drupal web root
COPY --chown=www-data:www-data index.php ${DRUPAL_ROOT}/web/index.php
COPY --chown=www-data:www-data templates/page.html.twig ${DRUPAL_ROOT}/web/core/themes/olivero/templates/layout/page.html.twig
COPY --chown=www-data:www-data static ${DRUPAL_ROOT}/web/static
# Copy Nginx configuration
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
RUN rm -f /etc/nginx/sites-enabled/default

# Set writable directories for Drupal
RUN mkdir -p ${DRUPAL_ROOT}/web/sites/default/files && \
    chown -R www-data:www-data ${DRUPAL_ROOT}/web/sites/default && \
    chmod 755 ${DRUPAL_ROOT}/web/sites/default && \
    chmod -R 775 ${DRUPAL_ROOT}/web/sites/default/files

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

# Run entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
