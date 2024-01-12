# https://stackoverflow.com/a/14061796/2237879
#
# This hack allows you to run make commands with any set of arguments.
#
# For example, these lines are the same:
#   > make one-test spec/path/here.rb
#   > bundle exec rspec spec/path/here.rb
RUN_ARGS := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))

build:  ## First time local dev setup
	if [ ! -f .env ]; then cp .env.template .env; fi;
	docker-compose build
	docker-compose run --rm rails bin/rails db:create
	docker-compose run --rm rails bin/rails db:migrate

up:  ## Start the docker containers
	docker-compose up

down:  ## Stop the docker containers
	docker-compose down

run:  ## Run provided command in rails docker container
	docker-compose run --rm rails $(RUN_ARGS)

consumer:  ## Run the Karafka consumer server stand alone
	docker-compose run --rm rails bundle exec karafka server

rails:
	docker-compose run --rm rails rails s -p 3001 -b '0.0.0.0'

up-test:  ## Start the docker containers for testing environment
	docker-compose -f docker-compose.test.yml up -d

down-test:  ## Stop the docker containers for testing environment
	docker-compose -f docker-compose.test.yml down

run-test:  ## Run provided command in rails docker container for test environment
	docker-compose -f docker-compose.test.yml run --rm test $(RUN_ARGS)

registry:  ## Upload schema AVRO to the Schema Registry
	docker-compose run --rm rails /usr/bin/kafka_schema.sh
