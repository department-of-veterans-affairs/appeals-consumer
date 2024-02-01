ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim

ENV SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"

# Install VA Trusted Certificates
RUN mkdir -p /usr/local/share/ca-certificates/va

COPY docker-bin/ca-certs/*.crt /usr/local/share/ca-certificates/va/

RUN update-ca-certificates
# End VA Trusted Certificates

RUN apt-get update -qq && apt-get install -y build-essential apt-utils libpq-dev supervisor jq curl

WORKDIR /appeals-consumer

COPY Gemfile* ./

RUN gem install bundler:$(cat Gemfile.lock | tail -1 | tr -d " ")

RUN bundle install

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ARG DEFAULT_PORT 3000

EXPOSE ${DEFAULT_PORT}

COPY docker-bin/. /usr/bin/

RUN chmod +x /usr/bin/startup.sh

ENTRYPOINT ["startup.sh"]
