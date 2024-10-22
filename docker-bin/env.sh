#!/bin/sh

export POSTGRES_HOST=db
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres
export RAILS_ENV=development
export DOCKERIZED=true
export SHORYUKEN_SQS_ENDPOINT=http://localstack-consumer:4666
export REDIS_URL_CACHE=redis://redis:7936/0
export SCHEMA_REGISTRY_URL=http://schema-registry:9021/
export CSS_ID=APPEALSCONSUMER1
export STATION_ID=283
export CASEFLOW_KEY=5ecb5d7b440e429bb5fac331419c7e1a
