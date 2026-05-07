FROM php:8.2-cli

RUN apt-get update && apt-get install -y \
    libsqlite3-dev zip unzip git curl \
    && docker-php-ext-install pdo pdo_sqlite \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

COPY . .
RUN composer run-script post-autoload-dump

RUN cp .env.example .env \
    && php artisan key:generate --force \
    && touch database/database.sqlite \
    && php artisan migrate --seed --force

RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache

EXPOSE ${PORT:-8080}
CMD php artisan serve --host=0.0.0.0 --port=${PORT:-8080}
