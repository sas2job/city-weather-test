### Стек проекта

• rails 8.0
• ruby 3.4
• postgres 17
• tailwind
• nats server 2.11
• docker 28.3
• rspec
• cucumber

### Настройка и запуск
1. Склонируйте репозиторий и перейдите в него 
```console
git clone git@github.com:sas2job/city-weather-test.git
cd city-weather-test
```
2. Скопируйте ключи и переменные:
```console
$ cp .env.sample .env
$ cp .env.test.sample .env.test
```
3. Пропишите в файле своё значение ключа
```bash
WEATHER_API_KEY=
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_HOST=

POSTGRES_DB_NAME=
```
4. Создайте контейнер
```console
$ docker compose build
```
5. Запустите контейнер
```console
$ docker compose up
```
6. Либо выполнив объединенную команду
```console
$ docker compose up --build
```

### Создание базы данных

Перед запуском приложения и тестов необходимо создать и подготовить базы данных:

1. Создание и миграции базы для приложения
```console
$ docker compose exec viewer bin/rails db:create db:migrate - для разработки
$ docker compose exec viewer bin/rails db:create RAILS_ENV=test - для тестов
```
2. Подготовка базы для тестов
```console
docker compose exec -e RAILS_ENV=test viewer bin/rails db:test:prepare
```
3. Тестирование
- Запуск всех тестов для получалки (RSpec):
```console
docker compose exec fetcher-sidekiq bundle exec rspec - запуск тестов
```
- Запуск тестов для отображалки
```console
$ docker compose exec viewer bash
$ bundle exec rspec
```
После выполнения тестов формируется отчёт о покрытии кода в директории:

fetcher/coverage/index.html - получалка
viewer/coverage/index.html - отображалка