#!/bin/sh

export POSTGRES_HOST=db
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres
export RAILS_ENV=development
export DOCKERIZED=true
export SHORYUKEN_SQS_ENDPOINT=http://localstack-consumer:4566
export REDIS_URL_CACHE=redis://appeals-consumer-redis-1:6379/0
export SCHEMA_REGISTRY_URL=http://schema-registry:9021/
export CSS_ID=APPEALSCONSUMER1
export STATION_ID=283
export CASFLEOW_KEY=12345
