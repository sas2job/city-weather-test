FROM ruby:3.4.3-slim

RUN apt-get -o Acquire::Check-Valid-Until=false update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      tzdata \
      libyaml-dev \
      libpq-dev \
      git \
      curl \
      nodejs \
      npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install bundler -v "~> 2.7"

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

COPY . .

RUN npm install -g yarn && yarn install --check-files

EXPOSE 3000

CMD ["bash", "-c", "bin/rails s -b 0.0.0.0 -p 3000"]