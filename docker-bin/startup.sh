#!/bin/bash
set -e

THIS_SCRIPT_DIR=$(dirname $0)

# Set variables for application
source $THIS_SCRIPT_DIR/env.sh

# Check for existing postgres server file and remove it
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

echo "Preparing DB in PG"
rake db:create

echo "Running migrations"
rake db:migrate

exec "$@"
