#!/bin/bash -eux

echo "Downloading chat server version ${CHAT_SERVER_VERSION}"

REPO="exo"
if [[ "${CHAT_SERVER_VERSION}" =~ "SNAPSHOT" ]]; then
    REPO="n/exo-addons-snapshots"
fi

DOWNLOAD_URL=http://addons.exoplatform.org/${REPO}/${GROUP_ID}/${ARTIFACT_ID}/${VERSION}/zip

wget -O chatserver.zip ${DOWNLOAD_URL}
