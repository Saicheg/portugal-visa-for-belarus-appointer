# Portugal Visa for Belarus Script

This script is used to automate the process of requesting appointment for Portugal Visa.

## How to use

* Create a [new app password](https://myaccount.google.com/apppasswords) in your gmail account.
* Copy `.env.sample` to `.env` and modify it with your data.
* Copy `body.txt.sample` to `body.txt` and modify it with your data.
* Place under `attachments/` folder PDF files you want to attach to the email.
* Build the docker image: `docker compose build`
* Run the script: `docker compose up -d`

## Attachments

Even if this script allows you to attach files to the email, it is not recommended. Our tests show that each 1MB of attachments increases the delivery time of your email to up to 10 seconds. If you need to attach files, consider uploading them somewhere and sending the link in the email.
