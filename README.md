# Standalone chat server Docker Image

| Image  | Chat server version | MongoDb Version
|--------|---------------------|-----------------
| latest | 1.5.0               | 3.0


This image is only for the chat server, you must have an external mongo database running.

## Configuration

### Chat properties

| VARIABLE                | MANDATORY | DEFAULT_VALUE           | DESCRIPTION
|-------------------------|-----------|-------------------------|-------------------------------------------
| CHAT_MONGO_HOST         | NO        | mongo                   | The mongo db database host name
| CHAT_MONGO_PORT         | NO        | 27017                   | The port to connect on mongodb server
| CHAT_MONGO_DB_NAME      | NO        | chat                    | The mongodb database name to use for eXo Chat
| CHAT_MONGO_DB_USER      | NO        |                         | the username to use to connect to the mongodb database (no authentification configured by default)
| CHAT_MONGO_DB_PASSWORD  | NO        |                         | the password to use to connect to the mongodb database (no authentification configured by default)
| CHAT_PORTAL_PAGE        | NO        | /portal/intranet/chat   | The page to link on the notifications
| CHAT_PASSPHRASE         | YES       |                         | The chat passphrase. The same value must be used by the eXo Platform server
| CHAT_CRON_NOTIF_CLEANUP | NO        | 0 0/60 * * * ?          | The cron expression to configure the notification cleanup
| CHAT_READ_DAYS          | NO        | 30                      | The messages older then ``CHAT_READ_DAYS`` days will not be displayed on a room
| CHAT_READ_TOTAL_JSON    | NO        | 200                     | The maximum number of messages to retrieve

### SMTP

| VARIABLE                | MANDATORY | DEFAULT_VALUE           | DESCRIPTION
|-------------------------|-----------|-------------------------|-------------------------------------------
| CHAT_SMTP_HOST          | NO        | `localhost`             | SMTP Server hostname
| CHAT_SMTP_PORT          | NO        | `25`                    | SMTP Server port
| CHAT_SMTP_USER          | NO        | -                       | authentication username for smtp server (if needed)
| CHAT_SMTP_PASSWORD      | NO        | -                       | authentication password for smtp server (if needed)
| CHAT_SMTP_FROM          | NO        | `noreply@exoplatform.com` | "from" field of emails sent by the chat server
| CHAT_SMTP_STARTTLS_ENABLED | NO     | `false`                 | true to enable the secure (TLS) SMTP. See RFC 3207.
| CHAT_SMTP_SSL_ENABLED   | NO        | `false`                 | true to enable the secure (SSL) SMTP.

## Usage

```
docker run -ti -p 8080:8080 -e CHAT_PASSPHRASE=changeme --link mongo:mongo exoplatform/chat-server:latest
```

# Known limitation

* The meeting notes can't be sent if the chatserver can reach the eXo Platform server via a public address

# TODO

[ ] Reduce image size
