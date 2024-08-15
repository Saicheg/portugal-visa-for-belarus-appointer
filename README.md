# Portugal Visa for Belarus Script

This script is used to automate the process of requesting appointment for Portugal Visa.

## How to use

* Copy `.env.sample` to `.env` and modify it with your data.
* Copy `body.txt.sample` to `body.txt` and modify it with your data.
* Place under `attachments/` folder PDF files you want to attach to the email.
* Build the docker image: `docker compose build`
* Run the script: `docker compose up -d`
