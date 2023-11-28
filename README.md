# Kafka Consumer

Kafka Consumer is an Rails application responsible for processing intake data sent by VBMS. When VBMS handles an intake, they will pushlish a message containing the relevent data to a Apache Kafka platform. This application will consume that data through a topic subscription. Kafka Consumer is also responsible for transforming the data to be sent to the Caseflow application. 

Homebrew Installation
---
1. Install homebrew from self-service portal

Docker Installation
---
Note: We do not use Docker Desktop due to licensing. We recommend using Colima to run the docker service.

1. Open terminal and run:
    1. `brew install docker docker-compose colima`
    2. `mkdir -p ~/.docker/cli-plugins`
    3. `ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose`

Clone the repo
---
1. Create a `~/dev/appeals/` directory

2. Clone the following repo using `git clone` into this directory
    * <https://github.com/Aaron-Willis/Kafka-Consumer.git>

Running the Application
---
1. Build the docker containers and run the database creation and migrations (First time only)

```bash
make build
```

2. Start the containers

```bash
make up
```

3. Run commands with `make run <COMMAND>`
Example:
```bash
make run rails c
```
