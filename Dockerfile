# Dockerizing eXo Platform Chat standalone:
#
# Build:    docker build -t exoplatform/chat-server .
#
# Run:      docker run -ti --rm --name=exo -p 80:8080 exoplatform/chat-server
#           docker run -d --name=exo -p 80:8080 exoplatform/chat-server

# ----- build step 1
FROM  exoplatform/jdk:8-ubuntu-1804 AS install

ARG CHAT_SERVER_VERSION=3.3.0-20210908

COPY download.sh /
RUN chmod u+x /download.sh && sync && /download.sh
# COPY install.sh /
# RUN chmod u+x /install.sh && /install.sh

RUN cd /usr/local && unzip /chatserver.zip && mv chat-server-standalone-${CHAT_SERVER_VERSION} chat-server

# ----- build step 2
FROM  exoplatform/jdk:8-ubuntu-1804
LABEL maintainer="eXo Platform <docker@exoplatform.com>"

# Install the needed packages
RUN apt-get -qq update && \
  apt-get -qq -y upgrade ${_APT_OPTIONS} && \
  apt-get -qq -y install ${_APT_OPTIONS} xmlstarlet && \
  apt-get -qq -y autoremove && \
  apt-get -qq -y clean && \
  rm -rf /var/lib/apt/lists/*

ENV CHAT_APP_DIR            /opt/chat-server
ENV CHAT_CONF_DIR           /etc/chat-server
ENV CHAT_LOG_DIR            /var/log/chat-server

ENV EXO_USER=exo

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# (we use 999 as uid like in official Docker images)
RUN useradd --create-home -u 999 --user-group --shell /bin/bash ${EXO_USER}

COPY --chown=999 --from=install /usr/local/chat-server ${CHAT_APP_DIR}
COPY --chown=999 bin/setenv.sh ${CHAT_APP_DIR}/bin/setenv-customize.sh

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN chmod u+x ${CHAT_APP_DIR}/bin/setenv-customize.sh \
    && ln -s ${CHAT_APP_DIR}/conf ${CHAT_CONF_DIR} \
    && mkdir -p ${CHAT_LOG_DIR}                     && chown ${EXO_USER} ${CHAT_LOG_DIR} \
    && rm -rf ${CHAT_APP_DIR}/logs                  && ln -s ${CHAT_LOG_DIR} ${CHAT_APP_DIR}/logs

EXPOSE 8080
USER ${EXO_USER}

ENTRYPOINT ["/usr/local/bin/tini", "--"]
CMD [ "/opt/chat-server/start_chatServer.sh" ]
