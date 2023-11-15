ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim

RUN apt-get update -qq && apt-get install -y build-essential apt-utils libpq-dev nodejs

WORKDIR /kafka-consumer

COPY . .

RUN gem install bundler:$(cat Gemfile.lock | tail -1 | tr -d " ")

RUN bundle install

ARG DEFAULT_PORT 3000

EXPOSE ${DEFAULT_PORT}

RUN chmod +x /kafka-consumer/docker-bin/startup.sh

ENTRYPOINT ["/bin/bash", "/kafka-consumer/docker-bin/startup.sh"]
