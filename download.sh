#!/bin/bash -eux

echo "Downloading chat server version ${CHAT_SERVER_VERSION}"

GROUP_ID=org.exoplatform.addons.chat
ARTIFACT_ID=chat-standalone-server-tomcat-distrib

if [[ "${CHAT_SERVER_VERSION}" =~ "SNAPSHOT" ]]; then
    # Download from nexus only for snapshot version
    DOWNLOAD_URL=http://addons.exoplatform.org/n/exo-addons-snapshots/${GROUP_ID}/${ARTIFACT_ID}/${CHAT_SERVER_VERSION}/zip
else
    # Using the public url for all other cases
    DOWNLOAD_URL=https://downloads.exoplatform.org/public/chat-standalone-server-tomcat-${CHAT_SERVER_VERSION}.zip
fi

#wget -O chatserver.zip ${DOWNLOAD_URL}
curl -sS -L -o /chatserver.zip ${DOWNLOAD_URL}