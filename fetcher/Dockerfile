FROM ruby:3.4.3-slim

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  tzdata \
  libyaml-dev \
  && rm -rf /var/lib/apt/lists/*

# build-essential          — для сборки нативных расширений
# libyaml-dev              — для работы с YAML
# tzdata                   — для настройки часового пояса

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

CMD ["bundle", "exec", "sidekiq", "-C", "config/sidekiq.yml"]