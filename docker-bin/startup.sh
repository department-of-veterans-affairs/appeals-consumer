#!/bin/bash

THIS_SCRIPT_DIR=$(dirname $0)

# Set variables for application
source $THIS_SCRIPT_DIR/env.sh

# Check for existing postgres server file and remove it
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi


echo "Creating DB in PG"
rake db:setup

echo "Starting Kafka-Consumer App RoR"
rails server --binding 0.0.0.0 -p 3000
