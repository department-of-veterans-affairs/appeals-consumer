# Mac
---
[<< Back](README.md)

---
### Homebrew Installation

1. Install homebrew from self-service portal

---
### Docker Installation

Note: We do not use Docker Desktop due to licensing. We recommend using Colima to run the docker service.

1. Open terminal and run:
    1. `brew install docker docker-compose colima`
    2. `mkdir -p ~/.docker/cli-plugins`
    3. `ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose`

---
### Clone the repo

1. Create a `~/dev/appeals/` directory

2. Clone the following repo using `git clone` into this directory
    * <https://github.com/department-of-veterans-affairs/appeals-consumer.git>

---
### Running the Application

1. Build the docker containers and run the database creation and migrations (First time only). Additionally, we need to upload the schema to the regestry server.

```bash
make build
make registry
```

2. Start the containers
   1. start both rails and the karafka consumer together
    ```bash
    make up
    ```
   2. Alternately, you can start the rails application or the Karafka consumer separately.
    ```bash
    make rails
    === OR ===
    make consumer
    ```


3. Run commands with `make run-cmd <COMMAND>`

Example:
```bash
make run-cmd rails c
```

### Database connection with DBeaver setup

1. Download and install DBeaver if you haven't already.
2. In your console run `make up`.
3. Open DBeaver and select Database on the top bar, then click 'New Database Connection'.
4. Select PostgreSQL and click next.
5. Change the port to 5555 (the exposed postgres port found in docker-compose.yml).
6. Enter the password: postgres (this is also found in docker-compose.yml).
7. Click the PostgreSQL tab and select 'Show all databases'.
8. Click Finish. The database should be viewable now on the left bar.

### Caseflow - Consumer development connection

1. Open a terminal and cd to your caseflow directory.
   - Run `make run` (or `make run-m1`) and then open the rails console: `rails c`

2. In a terminal in the appeals-consumer directory run `make build` and then `make run`
   - To test the connection, in a seperate terminal, open the consumer rails console with `make run-cmd rails c`
   - Copy and paste the following: `event = FactoryBot.create(:decision_review_created_event, message_payload: "{}")`
   - Run `event.process!`
   - There should be a response from caseflow that looks something like this: `[CaseflowService] #<HTTPI::Response:0x00007f3c7e1a1640>`
   - If the terminal output is too long and you are unable to scroll up far enough to see the CaseflowService response, in your terminal 
   settings increase your scroll limit to unlimited. You may need to `event.process!` again.