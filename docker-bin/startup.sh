#!/bin/bash
set -e

THIS_SCRIPT_DIR=$(dirname $0)

# Set variables for application
source $THIS_SCRIPT_DIR/env.sh

# Check for existing postgres server file and remove it
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

while ! curl -s http://schema-registry:9021/ > /dev/null; do
  echo "Waiting for Schema-registry to be ready..."
  sleep 15
done

echo "Schema-registry is ready."

source $THIS_SCRIPT_DIR/decision_review_created_kafka_schema.sh
source $THIS_SCRIPT_DIR/decision_review_updated_schema_registry.sh

while ! curl -s http://localstack-consumer:4566/_localstack/health  | grep -q -E '"sqs": "available"|"sqs": "running"'; do
  echo "Waiting for LocalStack to be ready..."
  sleep 15
done

echo "LocalStack is ready."

exec "$@"
