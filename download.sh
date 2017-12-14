#!/bin/bash -eux

echo "Downloading chat server version ${CHAT_SERVER_VERSION}"

REPO="exo"
if [[ "${CHAT_SERVER_VERSION}" =~ "SNAPSHOT" ]]; then
    REPO="n/exo-addons-snapshots"
elif [[ "${CHAT_SERVER_VERSION}" =~ "-RC" ]] || [[ "${CHAT_SERVER_VERSION}" =~ "-M" ]]; then
    REPO="n/exo-addons-releases"
fi

DOWNLOAD_URL=http://addons.exoplatform.org/${REPO}/${GROUP_ID}/${ARTIFACT_ID}/${CHAT_SERVER_VERSION}/zip

wget -O chatserver.zip ${DOWNLOAD_URL}
