# Standalone chat server Docker Image <!-- omit in toc -->

| Image      | Chat server version | MongoDb Version |
|------------|---------------------|-----------------|
| latest     | 3.0.x               | 4.4             |
| 3.2_latest | 3.0.x               | 4.2             |
| 3.1_latest | 3.0.x               | 4.0             |
| 3.0_latest | 3.0.x               | 4.0             |
| 2.3_latest | 2.3.x               | 4.0             |
| 2.2_latest | 2.2.x               | 4.0             |
| 2.1_latest | 2.1.x               | 3.6             |
| 2.0_latest | 2.0.x               | 3.4             |

This image is only for the chat server, you must have an external mongo database running.

- [Configuration](#configuration)
  - [Chat](#chat)
  - [JVM](#jvm)
  - [MongoDB](#mongodb)
  - [SMTP](#smtp)
  - [JMX](#jmx)
  - [Tomcat](#tomcat)
  - [Log](#log)
- [Usage](#usage)
- [Known limitation](#known-limitation)

## Configuration

### Chat

| VARIABLE                | MANDATORY | DEFAULT_VALUE           | DESCRIPTION                                                                                  |
|-------------------------|-----------|-------------------------|----------------------------------------------------------------------------------------------|
| CHAT_HTTP_PORT          | NO        | `8080`                  | The server http port to bind to                                                              |
| CHAT_SERVER_STOP_PORT   | NO        | `8005`                  | The server port used to stop it                                                              |
| CHAT_PORTAL_PAGE        | NO        | `/portal/intranet/chat` | The page to link on the notifications                                                        |
| CHAT_PASSPHRASE         | YES       |                         | The chat passphrase. The same value must be used by the eXo Platform server                  |
| CHAT_CRON_NOTIF_CLEANUP | NO        | `0 0/60 * * * ?`        | The cron expression to configure the notification cleanup                                    |
| CHAT_READ_DAYS          | NO        | `30`                    | The messages older then ``CHAT_READ_DAYS`` days will not be displayed on a room              |
| CHAT_READ_TOTAL_JSON    | NO        | `200`                   | The maximum number of messages to retrieve                                                   |
| CHAT_DB_TIMEOUT         | NO        | `60`                    | the number of seconds to wait for mongodb availability before cancelling Chat Server startup |

### JVM

The standard eXo Platform environment variables can be used :

| VARIABLE                   | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                      |
| -------------------------- | --------- | ------------- | ------------------------------------------------------------------------------------------------ |
| EXO_JVM_SIZE_MIN           | NO        | `512m`        | specify the jvm minimum allocated memory size (-Xms parameter)                                   |
| EXO_JVM_SIZE_MAX           | NO        | `3g`          | specify the jvm maximum allocated memory size (-Xmx parameter)                                   |
| EXO_JVM_METASPACE_SIZE_MAX | NO        | `512m`        | (Java 8+) specify the jvm maximum allocated memory to MetaSpace (-XX:MaxMetaspaceSize parameter) |
| EXO_JVM_USER_LANGUAGE      | NO        | `en`          | specify the jvm locale for langage (-Duser.language parameter)                                   |
| EXO_JVM_USER_REGION        | NO        | `US`          | specify the jvm local for region (-Duser.region parameter)                                       |
| EXO_JVM_LOG_GC_ENABLED     | NO        | `false`       | activate the JVM GC log file generation (location: $EXO_LOG_DIR/platform-gc.log)               |

### MongoDB

| VARIABLE               | MANDATORY | DEFAULT_VALUE | DESCRIPTION                                                                                        |
|------------------------|-----------|---------------|----------------------------------------------------------------------------------------------------|
| CHAT_MONGO_DB_HOST     | NO        | `mongo`       | The mongo db database host name                                                                    |
| CHAT_MONGO_DB_PORT     | NO        | `27017`       | The port to connect on mongodb server                                                              |
| CHAT_MONGO_DB_NAME     | NO        | `chat`        | The mongodb database name to use for eXo Chat                                                      |
| CHAT_MONGO_DB_USER     | NO        |               | the username to use to connect to the mongodb database (no authentification configured by default) |
| CHAT_MONGO_DB_PASSWORD | NO        |               | the password to use to connect to the mongodb database (no authentification configured by default) |

### SMTP

| VARIABLE                   | MANDATORY | DEFAULT_VALUE             | DESCRIPTION                                         |
|----------------------------|-----------|---------------------------|-----------------------------------------------------|
| CHAT_SMTP_HOST             | NO        | `localhost`               | SMTP Server hostname                                |
| CHAT_SMTP_PORT             | NO        | `25`                      | SMTP Server port                                    |
| CHAT_SMTP_USER             | NO        | `-`                       | authentication username for smtp server (if needed) |
| CHAT_SMTP_PASSWORD         | NO        | `-`                       | authentication password for smtp server (if needed) |
| CHAT_SMTP_FROM             | NO        | `noreply@exoplatform.com` | "from" field of emails sent by the chat server      |
| CHAT_SMTP_STARTTLS_ENABLED | NO        | `false`                   | true to enable the secure (TLS) SMTP. See RFC 3207. |
| CHAT_SMTP_SSL_ENABLED      | NO        | `false`                   | true to enable the secure (SSL) SMTP.               |

### JMX

The following environment variables should be passed to the container in order to configure JMX :

| VARIABLE                    | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                                                                  |
|-----------------------------|-----------|---------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| EXO_JMX_ENABLED             | NO        | `false`       | activate JMX listener                                                                                                                        |
| EXO_JMX_RMI_REGISTRY_PORT   | NO        | `10001`       | JMX RMI Registry port                                                                                                                        |
| EXO_JMX_RMI_SERVER_PORT     | NO        | `10002`       | JMX RMI Server port                                                                                                                          |
| EXO_JMX_RMI_SERVER_HOSTNAME | NO        | `localhost`   | JMX RMI Server hostname                                                                                                                      |
| EXO_JMX_USERNAME            | NO        | -             | a username for JMX connection (if no username is provided, the JMX access is unprotected)                                                    |
| EXO_JMX_PASSWORD            | NO        | -             | a password for JMX connection (if no password is specified a random one will be generated and stored in /etc/chat-server/jmxremote.password) |

With `EXO_JMX_ENABLED=true` and the default parameters you can connect to JMX with `service:jmx:rmi://localhost:10002/jndi/rmi://localhost:10001/jmxrmi` without authentication.

### Tomcat

The following environment variables can be passed to the container to configure Tomcat settings

| VARIABLE               | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                  |
| ---------------------- | --------- | ------------- | ---------------------------------------------------------------------------- |
| EXO_HTTP_THREAD_MAX    | NO        | `200`         | maximum number of threads in the tomcat http connector                       |
| EXO_HTTP_THREAD_MIN    | NO        | `10`          | minimum number of threads ready in the tomcat http connector                 |
| EXO_ACCESS_LOG_ENABLED | NO        | `false`       | activate Tomcat access log with combine format and a daily log file rotation |

### Log

| VARIABLE                 | MANDATORY | DEFAULT_VALUE | DESCRIPTION             |
|--------------------------|-----------|---------------|-------------------------|
| EXO_LOGS_DISPLAY_CONSOLE | NO        | `false`       | Disable logs on console |

## Usage

```bash
docker run -ti -p 8080:8080 -e CHAT_PASSPHRASE=changeme --link mongo:mongo exoplatform/chat-server:latest
```

A sample Docker Compose file is also available to start eXo Chat Server + MongoDB ( https://github.com/exo-docker/exo-chat-server/blob/master/docker-compose.yml ) :

```bash
docker-compose -f ./docker-compose.yml up
```

## Known limitation

- The meeting notes can't be sent if the Chat Server can reach the eXo Platform server via a public address
