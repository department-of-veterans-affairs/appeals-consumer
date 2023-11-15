# https://stackoverflow.com/a/14061796/2237879
#
# This hack allows you to run make commands with any set of arguments.
#
# For example, these lines are the same:
#   > make one-test spec/path/here.rb
#   > bundle exec rspec spec/path/here.rb
RUN_ARGS := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))

build:  ## First time local dev setup
	docker-compose build

up:  ## Start the docker containers
	docker-compose up -d

down:  ## Stop the docker containers
	docker-compose down

run:  ## Run provided command in rails docker container
	docker-compose run --rm rails $(RUN_ARGS)

up-test:  ## Start the docker containers for testing environment
	docker-compose -f docker-compose.test.yml up -d

down-test:  ## Stop the docker containers for testing environment
	docker-compose -f docker-compose.test.yml down

run-test:  ## Run provided command in rails docker container for test environment
	docker-compose -f docker-compose.test.yml run --rm test $(RUN_ARGS)
