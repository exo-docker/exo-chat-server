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

if [ -z "${MONGO_DB_USER}" ]; then
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


CLASSPATH="$CLASSPATH":"$CATALINA_HOME/lib/slf4j-api-${SLF4J_VERSION}.jar"
CLASSPATH="$CLASSPATH":"$CATALINA_HOME/lib/jul-to-slf4j-${SLF4J_VERSION}.jar"
CLASSPATH="$CLASSPATH":"$CATALINA_HOME/lib/logback-classic-${LOGBACK_VERSION}.jar"
CLASSPATH="$CLASSPATH":"$CATALINA_HOME/lib/logback-core-${LOGBACK_VERSION}.jar"

CATALINA_OPTS="${CATALINA_OPTS} -Dlogback.configurationFile=\"${CATALINA_BASE}/conf/logback.xml\""
