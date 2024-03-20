# Windows with WSL
---
This setup guide assumes that you have already gone through the caseflow setup:
[Windows 10](https://github.com/department-of-veterans-affairs/caseflow/blob/master/WINDOWS_10.md)
[Windows 11](https://github.com/department-of-veterans-affairs/caseflow/blob/master/WINDOWS_11.md)

[<< Back](README.md)

---
### Homebrew Installation

Install homebrew from self-service portal [Brew installation page](https://brew.sh/)
  1. Paste and enter the following in your terminal: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
  2. Follow the instructions under "Next Steps" after the installation has finished. 

---
### Docker Installation

Note: We do not use Docker Desktop due to licensing.

Open terminal and run:
  1. `brew install docker docker-compose`
  2. `mkdir -p ~/.docker/cli-plugins`
  3. `ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose`

---
### Clone the repo

1. Create or cd into your `~/appeals/` directory.

2. Clone the following repo using `git clone` into this directory
    * <https://github.com/department-of-veterans-affairs/appeals-consumer.git>

---
### Running the Application

1. Build the docker containers and run the database creation and migrations (First time only). Additionally, we need to upload the schema to the registry server.

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

#### Make sure you revert the appeals-consumer files (docker-compose, supervisord.conf, env.sh) changed through these steps before committing, and save the Caseflow ApiKey for future use

1. Open a terminal and cd to your caseflow directory.
   - Run `make run` and then open the rails console: `rails c`
   - Generate and copy a new api key: `ApiKey.create(consumer_name: "APPEALSCONSUMER1").key_string`

2. In the appeals-consumer directory:
   1. Open the ENV file: appeals-consumer/docker-bin/env.sh and add: 
      - `export CASEFLOW_KEY=<ApiKey value you created in caseflow console>`
      - `export CASEFLOW_URL=http://127.0.0.1:3000`
   2. Open the supervisord.conf file and change `3000` to `3001` under `program:rails`
   3. Open docker-compose.yml go down to the `rails` section
      - Above `build`, add `network_mode: "host"`
      - Comment out `networks` and its nested line

3. In your VSCode terminal open the `ports` page, click `Add Port` and enter `3001`

4. In a terminal in the appeals-consumer directory run `make build` and then `make run`
   - To test the connection, in a seperate terminal, open the consumer rails console with `make run-cmd rails c`
   - Copy and paste the following: `event = FactoryBot.create(:decision_review_created_event, message_payload: "{}")`
   - Run `event.process!`
   - There should be a response from caseflow that looks something like this: `[CaseflowService] #<HTTPI::Response:0x00007f3c7e1a1640>`

Notes:
  - The `CASEFLOW_URL` value `127.0.0.1` here is the port that caseflow is shown under the ports tab of VSCode terminal