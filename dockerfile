FROM elrincondeisma/octane:latest

# Instalar dependencias Alpine
RUN apk update && apk add --no-cache \
    unzip \
    git \
    curl \
    zip \
    libzip-dev

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# RoadRunner
COPY --from=spiralscout/roadrunner:2.4.2 /usr/bin/rr /usr/bin/rr

WORKDIR /app

# Copiamos composer primero para cache de Docker
COPY composer.json composer.lock ./

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1

# Instalar dependencias
RUN composer install \
    --no-dev \
    --prefer-dist \
    --optimize-autoloader \
    --no-interaction

# Copiamos el resto del proyecto
COPY . .

# Variables
RUN cp .env.example .env

# Permisos Laravel
RUN mkdir -p storage/logs bootstrap/cache && \
    chmod -R 777 storage bootstrap/cache

# Generar APP_KEY
RUN php artisan key:generate

# Limpiar caches
RUN php artisan optimize:clear || true

# Instalar Octane
RUN php artisan octane:install --server=roadrunner || true

EXPOSE 8000