#!/bin/bash -x

PROPERTY_FILE=${CATALINA_HOME}/conf/chat.properties

if [ -e "${PROPERTY_FILE}" ]; then
  echo "INFO: eXo Chat server configuration already exists, skipping configuration"
  return
fi

# $1 : the full line content to insert at the end of Chat configuration file
add_in_chat_configuration() {
  local _CONFIG_FILE="${PROPERTY_FILE}"
  local P1="$1"
  echo "${P1}" >> ${_CONFIG_FILE}
}

# Chat server configuration
[ -z "${CHAT_MONGO_DB_HOST}" ] && CHAT_MONGO_DB_HOST="mongo"
[ -z "${CHAT_MONGO_DB_PORT}" ] && CHAT_MONGO_DB_PORT="27017"
[ -z "${CHAT_MONGO_DB_NAME}" ] && CHAT_MONGO_DB_NAME="chat"
[ -z "${CHAT_MONGO_DB_AUTHENTICATION}" ] && CHAT_MONGO_DB_AUTHENTICATION="false"
[ -z "${CHAT_MONGO_DB_USER}" ] && CHAT_MONGO_DB_USER=""
[ -z "${CHAT_MONGO_DB_PASSWORD}" ] && CHAT_MONGO_DB_PASSWORD=""
[ -z "${CHAT_PORTAL_PAGE}" ] && CHAT_PORTAL_PAGE="/portal/intranet/chat"
[ -z "${CHAT_PASSPHRASE}" ] && CHAT_PASSPHRASE="changeme"
[ -z "${CHAT_CRON_NOTIF_CLEANUP}" ] && CHAT_CRON_NOTIF_CLEANUP="0 0/60 * * * ?"
[ -z "${CHAT_READ_DAYS}" ] && CHAT_READ_DAYS="30"
[ -z "${CHAT_READ_TOTAL_JSON}" ] && CHAT_READ_TOTAL_JSON="200"
[ -z "${CHAT_PUBLIC_ADMIN_GROUP}" ] && CHAT_PUBLIC_ADMIN_GROUP="/platform/administrators"
# SMTP configuration
[ -z "${CHAT_SMTP_HOST}" ] && CHAT_SMTP_HOST=""
[ -z "${CHAT_SMTP_PORT}" ] && CHAT_SMTP_PORT=""
[ -z "${CHAT_SMTP_USER}" ] && CHAT_SMTP_USER=""
[ -z "${CHAT_SMTP_PASSWORD}" ] && CHAT_SMTP_PASSWORD=""
[ -z "${CHAT_SMTP_FROM}" ] && CHAT_SMTP_FROM="noreply@exoplatform.com"
[ -z "${CHAT_SMTP_STARTTLS_ENABLED}" ] && CHAT_SMTP_TLS_ENABLED="false"
[ -z "${CHAT_SMTP_SSL_ENABLED}" ] && CHAT_SMTP_SSL_ENABLED="false"

if [ -z "${CHAT_MONGO_DB_USER}" ]; then
    add_in_chat_configuration "dbAuthentication=false"
    add_in_chat_configuration "#dbUser="
    add_in_chat_configuration "#dbPassword="
else
    add_in_chat_configuration "dbAuthentication=true"
    add_in_chat_configuration "dbUser=${CHAT_MONGO_DB_USER}"
    add_in_chat_configuration "dbPassword=${CHAT_MONGO_DB_PASSWORD}"
fi

add_in_chat_configuration "standaloneChatServer=true"
add_in_chat_configuration "dbServerHost=${CHAT_MONGO_DB_HOST}"
add_in_chat_configuration "dbServerPort=${CHAT_MONGO_DB_PORT}"
add_in_chat_configuration "dbName=${CHAT_MONGO_DB_NAME}"
add_in_chat_configuration "chatPortalPage=${CHAT_PORTAL_PAGE}"
add_in_chat_configuration "chatPassPhrase=${CHAT_PASSPHRASE}"
add_in_chat_configuration "chatCronNotifCleanup=${CHAT_CRON_NOTIF_CLEANUP}"
add_in_chat_configuration "chatReadDays=${CHAT_READ_DAYS}"
add_in_chat_configuration "chatReadTotalJson=${CHAT_READ_TOTAL_JSON}"
add_in_chat_configuration "publicAdminGroup=${CHAT_PUBLIC_ADMIN_GROUP}"

# SMTP configuration
add_in_chat_configuration "email.smtp.host=${CHAT_SMTP_HOST}"
add_in_chat_configuration "email.smtp.port=${CHAT_SMTP_PORT}"
if [ -z "${CHAT_SMTP_USER}" ]; then
    add_in_chat_configuration "email.smtp.auth=false"
    add_in_chat_configuration "#email.smtp.username="
    add_in_chat_configuration "#email.smtp.password="
else
    add_in_chat_configuration "email.smtp.auth=true"
    add_in_chat_configuration "email.smtp.username=${CHAT_SMTP_USER}"
    add_in_chat_configuration "email.smtp.password=${CHAT_SMTP_PASSWORD}"
fi

add_in_chat_configuration "email.smtp.from=${CHAT_SMTP_FROM}"
add_in_chat_configuration "email.smtp.starttls.enable=${CHAT_SMTP_STARTTLS_ENABLED}"
add_in_chat_configuration "email.smtp.EnableSSL.enable=${CHAT_SMTP_SSL_ENABLED}"

CLASSPATH="$CLASSPATH":"$CATALINA_HOME/lib/slf4j-api-${SLF4J_VERSION}.jar"
CLASSPATH="$CLASSPATH":"$CATALINA_HOME/lib/jul-to-slf4j-${SLF4J_VERSION}.jar"
CLASSPATH="$CLASSPATH":"$CATALINA_HOME/lib/logback-classic-${LOGBACK_VERSION}.jar"
CLASSPATH="$CLASSPATH":"$CATALINA_HOME/lib/logback-core-${LOGBACK_VERSION}.jar"

CATALINA_OPTS="${CATALINA_OPTS} -Dlogback.configurationFile=\"${CATALINA_BASE}/conf/logback.xml\""
