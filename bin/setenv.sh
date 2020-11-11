#!/bin/bash -eu

PROPERTY_FILE=${CATALINA_HOME}/conf/chat.properties

# $1 : the full line content to insert at the end of Chat configuration file
add_in_chat_configuration() {
  local _CONFIG_FILE="${PROPERTY_FILE}"
  local P1="$1"
  if [ ! -f ${_CONFIG_FILE} ]; then
    echo "Creating Chat configuration file [${_CONFIG_FILE}]"
    touch ${_CONFIG_FILE}
    if [ $? != 0 ]; then
      echo "Problem during Chat configuration file creation, startup aborted !"
      exit 1
    fi
  fi
  echo "${P1}" >> ${_CONFIG_FILE}
}

# -----------------------------------------------------------------------------
# Check configuration variables and add default values when needed
# -----------------------------------------------------------------------------
set +u		# DEACTIVATE unbound variable check

[ -z "${CHAT_DB_TIMEOUT}" ] && CHAT_DB_TIMEOUT="60"
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

# Tomcat configuration
[ -z "${EXO_HTTP_THREAD_MIN}" ] && EXO_HTTP_THREAD_MIN="10"
[ -z "${EXO_HTTP_THREAD_MAX}" ] && EXO_HTTP_THREAD_MAX="200"

# JVM LOG GC configuration
[ -z "${EXO_JVM_LOG_GC_ENABLED}" ] && EXO_JVM_LOG_GC_ENABLED="false"

# JMX configuration
[ -z "${EXO_JMX_ENABLED}" ] && EXO_JMX_ENABLED="false"
[ -z "${EXO_JMX_RMI_REGISTRY_PORT}" ] && EXO_JMX_RMI_REGISTRY_PORT="10001"
[ -z "${EXO_JMX_RMI_SERVER_PORT}" ] && EXO_JMX_RMI_SERVER_PORT="10002"
[ -z "${EXO_JMX_RMI_SERVER_HOSTNAME}" ] && EXO_JMX_RMI_SERVER_HOSTNAME="localhost"
[ -z "${EXO_JMX_USERNAME}" ] && EXO_JMX_USERNAME="-"
[ -z "${EXO_JMX_PASSWORD}" ] && EXO_JMX_PASSWORD="-"

# Tomcat Access Log configuration
[ -z "${EXO_ACCESS_LOG_ENABLED}" ] && EXO_ACCESS_LOG_ENABLED="false"

# SMTP configuration
[ -z "${CHAT_SMTP_HOST}" ] && CHAT_SMTP_HOST=""
[ -z "${CHAT_SMTP_PORT}" ] && CHAT_SMTP_PORT=""
[ -z "${CHAT_SMTP_USER}" ] && CHAT_SMTP_USER=""
[ -z "${CHAT_SMTP_PASSWORD}" ] && CHAT_SMTP_PASSWORD=""
[ -z "${CHAT_SMTP_FROM}" ] && CHAT_SMTP_FROM="noreply@exoplatform.com"
[ -z "${CHAT_SMTP_STARTTLS_ENABLED}" ] && CHAT_SMTP_STARTTLS_ENABLED="false"
[ -z "${CHAT_SMTP_SSL_ENABLED}" ] && CHAT_SMTP_SSL_ENABLED="false"
set -u		# REACTIVATE unbound variable check

# -----------------------------------------------------------------------------
# Update some configuration files when the container is created for the first time
# -----------------------------------------------------------------------------
if [ -f ${CHAT_APP_DIR}/_done.configuration ]; then
  echo "INFO: Configuration already done! skipping this step."
else
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
  add_in_chat_configuration "dbServerHosts=${CHAT_MONGO_DB_HOST}:${CHAT_MONGO_DB_PORT}"
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

  ## Remove file comments
  xmlstarlet ed -L -d "//comment()" ${CHAT_APP_DIR}/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (xml comments removal)"
    exit 1
  }

  ## Remove AJP connector
  xmlstarlet ed -L -d '//Connector[@protocol="AJP/1.3"]' ${CHAT_APP_DIR}/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (AJP connector removal)"
    exit 1
  }

  # Tomcat HTTP Thread pool configuration
  xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "maxThreads" -v "${EXO_HTTP_THREAD_MAX}" \
    -s "/Server/Service/Connector" -t attr -n "minSpareThreads" -v "${EXO_HTTP_THREAD_MIN}" \
    -u "/Server/Service/Connector/@port" -v "${CHAT_HTTP_PORT:8080}" \
    ${CHAT_APP_DIR}/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (adding Connector proxyName)"
    exit 1
  }

  # JMX configuration
  if [ "${EXO_JMX_ENABLED}" = "true" ]; then
    # Create the security files if required
    if [ "${EXO_JMX_USERNAME:-}" != "-" ]; then
      if [ "${EXO_JMX_PASSWORD:-}" = "-" ]; then
        EXO_JMX_PASSWORD="$(tr -dc '[:alnum:]' < /dev/urandom  | dd bs=2 count=6 2>/dev/null)"
      fi
    # ${CHAT_APP_DIR}/conf/jmxremote.password
    echo "${EXO_JMX_USERNAME} ${EXO_JMX_PASSWORD}" > ${CHAT_APP_DIR}/conf/jmxremote.password
    # ${CHAT_APP_DIR}/conf/jmxremote.access
    echo "${EXO_JMX_USERNAME} readwrite" > ${CHAT_APP_DIR}/conf/jmxremote.access
    fi
  fi

  # Access log configuration
  if [ "${EXO_ACCESS_LOG_ENABLED}" = "true" ]; then
    # Add a new valve (just before the end of Host)
    xmlstarlet ed -L -s "/Server/Service/Engine/Host" -t elem -n "ValveTMP" -v "" \
      -i "//ValveTMP" -t attr -n "className" -v "org.apache.catalina.valves.AccessLogValve" \
      -i "//ValveTMP" -t attr -n "pattern" -v "combined" \
      -i "//ValveTMP" -t attr -n "directory" -v "logs" \
      -i "//ValveTMP" -t attr -n "prefix" -v "access" \
      -i "//ValveTMP" -t attr -n "suffix" -v ".log" \
      -i "//ValveTMP" -t attr -n "rotatable" -v "true" \
      -i "//ValveTMP" -t attr -n "renameOnRotate" -v "true" \
      -i "//ValveTMP" -t attr -n "fileDateFormat" -v ".yyyy-MM-dd" \
      -r "//ValveTMP" -v Valve \
      ${CHAT_APP_DIR}/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (adding AccessLogValve)"
      exit 1
    }
  fi

  # put a file to avoid doing the configuration twice
  touch ${CHAT_APP_DIR}/_done.configuration
fi

# -----------------------------------------------------------------------------
# JMX configuration
# -----------------------------------------------------------------------------
if [ "${EXO_JMX_ENABLED}" = "true" ]; then
  CATALINA_OPTS="${CATALINA_OPTS:-} -Dcom.sun.management.jmxremote=true"
  CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
  CATALINA_OPTS="${CATALINA_OPTS} -Djava.rmi.server.hostname=${EXO_JMX_RMI_SERVER_HOSTNAME}"
  if [ "${EXO_JMX_USERNAME:-}" = "-" ]; then
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.authenticate=false"
  else
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.authenticate=true"
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.password.file=${CHAT_APP_DIR}/conf/jmxremote.password"
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.access.file=${CHAT_APP_DIR}/conf/jmxremote.access"
  fi
fi

# -----------------------------------------------------------------------------
# LOG GC configuration
# -----------------------------------------------------------------------------
if [ "${EXO_JVM_LOG_GC_ENABLED}" = "true" ]; then
  # -XX:+PrintGCDateStamps : print the absolute timestamp in the log statement (i.e. “2014-11-18T16:39:25.303-0800”)
  # -XX:+PrintGCTimeStamps : print the time when the GC event started, relative to the JVM startup time (unit: seconds)
  # -XX:+PrintGCDetails    : print the details of how much memory is reclaimed in each generation
  EXO_JVM_LOG_GC_OPTS="-XX:+PrintGC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps"
  echo "Enabling eXo JVM GC logs with [${EXO_JVM_LOG_GC_OPTS}] options ..."
  CATALINA_OPTS="${CATALINA_OPTS:-} ${EXO_JVM_LOG_GC_OPTS} -Xloggc:${CHAT_LOG_DIR}/platform-gc.log"
  # log rotation to backup previous log file (we don't use GC Log file rotation options because they are not suitable)
  # create the directory for older GC log file
  [ ! -d ${CHAT_LOG_DIR}/platform-gc/ ] && mkdir ${CHAT_LOG_DIR}/platform-gc/
  if [ -f ${CHAT_LOG_DIR}/platform-gc.log ]; then
    EXO_JVM_LOG_GC_ARCHIVE="${CHAT_LOG_DIR}/platform-gc/platform-gc_$(date -u +%F_%H%M%S%z).log"
    mv ${CHAT_LOG_DIR}/platform-gc.log ${EXO_JVM_LOG_GC_ARCHIVE}
    echo "previous eXo JVM GC log file archived to ${EXO_JVM_LOG_GC_ARCHIVE}."
  fi
  echo "eXo JVM GC logs configured and available at ${CHAT_LOG_DIR}/platform-gc.log"
fi


echo "Waiting for mongodb availability at ${CHAT_MONGO_DB_HOST}:${CHAT_MONGO_DB_PORT} ..."
wait-for ${CHAT_MONGO_DB_HOST}:${CHAT_MONGO_DB_PORT} -s -t ${CHAT_DB_TIMEOUT}
if [ $? != 0 ]; then
  echo "[ERROR] The mongodb database ${CHAT_MONGO_DB_HOST}:${CHAT_MONGO_DB_PORT} was not available within ${CHAT_DB_TIMEOUT}s ! Chat Server startup aborted ..."
  exit 1
fi

set +u		# DEACTIVATE unbound variable check
