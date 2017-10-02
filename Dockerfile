#FROM tomcat:7.0.75-jre8
FROM  exoplatform/base-jdk:jdk8

ARG TOMCAT_VERSION=7.0.75
ARG TOMCAT_URL=http://archive.apache.org/dist/tomcat/tomcat-7/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
ARG CHAT_SERVER_VERSION=1.5.0
#ARG DOWNLOAD_URL=http://addons.exoplatform.org/exo/chat/exo-addons-chat-extension-pkg-standalone/${CHAT_SERVER_VERSION}/zip
ARG DOWNLOAD_URL=https://repository.exoplatform.org/public/org/exoplatform/addons/chat/exo-addons-chat-extension-pkg-standalone/1.5.0/exo-addons-chat-extension-pkg-standalone-1.5.0.zip

## Tomcat installation
RUN cd /usr/local && wget ${TOMCAT_URL} -O tomcat.tar.gz && tar xvzf tomcat.tar.gz && ln -s /usr/local/apache-tomcat-${TOMCAT_VERSION} /usr/local/tomcat && rm -rf /usr/local/tomcat/webapps/* && rm -v tomcat.tar.gz

## Chat server installation
RUN cd /tmp && wget -O exo-addons-chat-extension.zip ${DOWNLOAD_URL}
# TODO squash
RUN cd /tmp && unzip exo-addons-chat-extension.zip && unzip exo-addons-chat-extension/exo-addons-chat-server-${CHAT_SERVER_VERSION}.zip chatServer.war -d /usr/local/tomcat/webapps && rm -rf exo-addons-chat-extension*
RUN cd /usr/local/tomcat/webapps && unzip chatServer.war -d chatServer && rm -v chatServer/WEB-INF/lib/slf4j*

ENV SLF4J_VERSION=1.7.18
RUN wget https://repository.exoplatform.org/public/org/slf4j/slf4j-api/${SLF4J_VERSION}/slf4j-api-${SLF4J_VERSION}.jar -O /usr/local/tomcat/lib/slf4j-api-${SLF4J_VERSION}.jar
RUN wget https://repository.exoplatform.org/public/org/slf4j/jul-to-slf4j/${SLF4J_VERSION}/jul-to-slf4j-${SLF4J_VERSION}.jar -O /usr/local/tomcat/lib/jul-to-slf4j-${SLF4J_VERSION}.jar

ENV LOGBACK_VERSION=1.1.2
RUN wget https://repository.exoplatform.org/public/ch/qos/logback/logback-core/${LOGBACK_VERSION}/logback-core-${LOGBACK_VERSION}.jar -O /usr/local/tomcat/lib/logback-core-${LOGBACK_VERSION}.jar
RUN wget https://repository.exoplatform.org/public/ch/qos/logback/logback-classic/${LOGBACK_VERSION}/logback-classic-${LOGBACK_VERSION}.jar -O /usr/local/tomcat/lib/logback-classic-${LOGBACK_VERSION}.jar

COPY bin/setenv.sh /usr/local/tomcat/bin/
COPY conf/logback.xml /usr/local/tomcat/conf/
COPY conf/logging.properties /usr/local/tomcat/conf/

EXPOSE 8080

WORKDIR /usr/local/tomcat

CMD [ "/usr/local/tomcat/bin/catalina.sh", "run" ]
