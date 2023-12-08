ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim

RUN apt-get update -qq && apt-get install -y build-essential apt-utils libpq-dev supervisor jq curl

WORKDIR /kafka-consumer

COPY Gemfile* .

RUN gem install bundler:$(cat Gemfile.lock | tail -1 | tr -d " ")

RUN bundle install

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY . .

ARG DEFAULT_PORT 3000

EXPOSE ${DEFAULT_PORT}

COPY docker-bin/. /usr/bin/

RUN chmod +x /usr/bin/startup.sh

ENTRYPOINT ["startup.sh"]
