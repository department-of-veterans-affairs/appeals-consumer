# Kafka Consumer

Kafka Consumer is an Rails application responsible for processing intake data sent by VBMS. When VBMS handles an intake, they will pushlish a message containing the relevent data to a Apache Kafka platform. This application will consume that data through a topic subscription. Kafka Consumer is also responsible for transforming the data to be sent to the Caseflow application. 

[TOC]

## Developer Setup

### Machine setup

- [Mac](SETUP.md)
- Windows - TBD

### Development walkthrough

Building the containers
---

Running `make build` will build the initial docker containers. This will:
- Copy all necessary files into the docker container.
- Install required dependencies.
- Create the database if it has not already been created.
- Run any pending migrations

Starting the containers
---

Running `make up` will start up the docker compose environment for development. Any changes to the local code base will be reflected in the docker container with some exceptions. New migrations will need to be migrated to the containerized Postgres instance. Additionally, any modifications to the container environment, such as modifying the Dockerfile or supporting system level dependencies will require a rebuild of the containers.

Kafka Consumer utuilizes [Supervisor](http://supervisord.org/) to run multiple processes in parallel. The Rails server runs along side the Karafka consumer server when you run `make up`. The logs for these processes can be found in the project's `/log` directory, `/log/rails` and `/log/kafka`.

Kafka Broker instance
---

The Kafka Consumer docker compose includes a Kafka broker. The broker im age is [cp-kafka](https://docs.confluent.io/platform/current/installation/docker/config-reference.html#confluent-ak-configuration) which is downloaded from confluent. `cp-kafka` is based off of [librdkafka](https://karafka.io/docs/Librdkafka-Configuration/) and can be configured with all of the same properties. The `cp-kafka` is configured via environmental variables in the docker-compose file using their documented variable conversion rules. 
