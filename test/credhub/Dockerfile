FROM ubuntu

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk

ADD src/ /credhub

WORKDIR /credhub

RUN ./gradlew --no-daemon assemble
