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
.env              # Переменные

```console
$ cp .env.sample .env

Создание и запуск контейнера
3. Создайте контейнер
```console
$ docker compose build
```
4. Запускаем контейнер
```console
$ docker compose up
```
5. Либо выполнив объединенную команду
```console
$ docker compose up --build
```