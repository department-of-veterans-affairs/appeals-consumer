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
	docker compose build
	docker compose run --rm rails bin/rails db:create
	docker compose run --rm rails bin/rails db:migrate

up:  ## Start the docker containers
	docker compose up

down:  ## Stop the docker containers
	docker compose down

run:  ## Alias for make up to keep inline with Caseflow's process
	make up

run-cmd:  ## Run provided command in rails docker container
	docker compose run --rm rails $(RUN_ARGS)

consumer:  ## Run the Karafka consumer server stand alone
	docker compose run --rm rails bundle exec karafka server

rails:  ## Run the Rails server stand alone
	docker compose run --rm rails rails s -p 3001 -b '0.0.0.0'

all-test:
	docker compose run --rm rails rspec

one-test:
	docker compose run --rm rails rspec $(RUN_ARGS)

registry:  ## Upload schema AVRO to the Schema Registry
	docker compose run --rm rails /usr/bin/decision_review_created_schema_registry.sh && \
	docker compose run --rm rails /usr/bin/decision_review_updated_schema_registry.sh

run-all-queues: ## start shoryuken with all queues
	docker compose run --rm rails bundle exec shoryuken -q appeals_consumer_development_high_priority appeals_consumer_development_low_priority -R

run-low-priority: ## start shoryuken with just the low priority queue
	docker compose run --rm rails bundle exec shoryuken -q appeals_consumer_development_low_priority -R

run-high-priority: ## start shoryuken with just the high priority queue
	docker compose run --rm rails bundle exec shoryuken -q appeals_consumer_development_high_priority -R

publish-decision-review-created-events: ## publish DecisionReviewCreated event messages to test consumption
	docker compose run --rm rails bundle exec rake kafka_message_generators:decision_review_created_events[decision_review_created]

publish-decision-review-updated-events: ## publish DecisionReviewUpdated event messages to test consumption
	docker compose run --rm rails bundle exec rake kafka_message_generators:decision_review_created_events
