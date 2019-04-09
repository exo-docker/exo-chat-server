# Changelog <!-- omit in toc -->

Changelog for `exoplatform/chat-server:2.2.*_*` Docker image

- [2.2.0_1 [2019-04-09]](#220_1-2019-04-09)
- [2.2.0_0 [2019-04-01]](#220_0-2019-04-01)

## 2.2.0_1 [2019-04-09]

- **Upgrades**
  - change base image to exoplatform/jdk:8-ubuntu-1804
  - rework the image build to be close to exoplatform/exo* images

- **Features**
  - add Tomcat HTTP thread pool configuration
  - add Tomcat Access Log capability
  - add JVM loggc capability
  - add JMX capability

- **Samples**
  - add a Docker Compose sample file

- **Documentation**
  - document some eXo JVM parameters
  - documentation refactoring

## 2.2.0_0 [2019-04-01]

- **Upgrades**
  - upgrade to eXo Chat Server 2.2.0 GA
