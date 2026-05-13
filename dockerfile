FROM elrincondeisma/octane:latest

# Dependencias Alpine
RUN apk update && apk add --no-cache \
    git \
    unzip \
    curl \
    zip \
    libzip-dev \
    oniguruma-dev \
    icu-dev \
    autoconf \
    g++ \
    make

# Instalar extensiones PHP necesarias
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    mbstring \
    zip \
    intl

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# RoadRunner
COPY --from=spiralscout/roadrunner:2.4.2 /usr/bin/rr /usr/bin/rr

WORKDIR /app

# Copiar composer primero
COPY composer.json composer.lock ./

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1

# Limpiar cache composer
RUN composer clear-cache

# Instalar dependencias SIN scripts
RUN composer install \
    --no-dev \
    --no-scripts \
    --prefer-dist \
    --optimize-autoloader \
    --no-interaction \
    --ignore-platform-reqs

# Copiar proyecto
COPY . .

# ENV
RUN cp .env.example .env

# APP KEY
RUN php artisan key:generate || true

# Permisos
RUN chmod -R 777 storage bootstrap/cache || true

# Cache Laravel
RUN php artisan optimize:clear || true

# Instalar Octane
RUN php artisan octane:install --server=roadrunner || true

EXPOSE 8000