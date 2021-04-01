# Application Metadata
ARG APP_PORT=8080
ARG MAVEN_IMAGE_TAG=3.6.3-openjdk-8-slim
ARG JAVA_IMAGE_TAG=8-slim

FROM maven:${MAVEN_IMAGE_TAG} as builder

COPY pom.xml /usr/app/
COPY src /usr/app/src
WORKDIR /usr/app/

RUN mvn package -Dmaven.test.skip=true

FROM openjdk:${JAVA_IMAGE_TAG}
ARG APPLICATION_NAME
ARG VERSION
ARG APP_PORT
ENV TERM=xterm-256color

RUN apt-get update && apt-get install -y curl 
    
COPY --from=builder /usr/app/target/ /app/

EXPOSE ${APP_PORT}
WORKDIR /app

RUN chmod +x bin/start
ENTRYPOINT sh -x bin/start
