# IMAGEN BASE
FROM elrincondeisma/octane:latest

# INSTALAR DEPENDENCIAS EN ALPINE
RUN apk update && apk add --no-cache \
    unzip \
    git \
    libzip-dev \
    zip \
    curl

# INSTALAR COMPOSER
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# INSTALAR ROADRUNNER
COPY --from=spiralscout/roadrunner:2.4.2 /usr/bin/rr /usr/bin/rr

# DIRECTORIO DE TRABAJO
WORKDIR /app

# COPIAR PROYECTO
COPY . .

# LIMPIAR VENDOR
RUN rm -rf vendor

# VARIABLES
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1

# INSTALAR DEPENDENCIAS PHP
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# INSTALAR OCTANE Y ROADRUNNER
RUN composer require laravel/octane spiral/roadrunner

# CONFIGURAR ENV
RUN cp .env.example .env

# PERMISOS
RUN mkdir -p storage/logs bootstrap/cache && \
    chmod -R 777 storage bootstrap/cache

# LIMPIAR CACHE
RUN php artisan cache:clear || true
RUN php artisan config:clear || true
RUN php artisan view:clear || true

# INSTALAR OCTANE
RUN php artisan octane:install --server=roadrunner || true

# EXPONER PUERTO
EXPOSE 8000
