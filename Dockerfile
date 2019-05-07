FROM openjdk:8u151-jdk

LABEL maintainer "Bernhard Wittmann <dev@bernhardwittmann.com>"

ENV GOSU_VERSION 1.10

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     vim \
     wget \
 && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
 && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
 && chmod +x /usr/local/bin/gosu \
 && gosu nobody true \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
 
RUN groupadd -r ijinspector && useradd --no-log-init --gid ijinspector --home-dir /home/ijinspector --create-home ijinspector

WORKDIR /home/ijinspector

USER ijinspector:ijinspector

ARG IDEA_VERSION=ideaIC-2019.1.1
ARG idea_source=https://download.jetbrains.com/idea/ideaIC-2019.1.1.tar.gz
ARG idea_local_dir=.IdeaIC2019.1

RUN curl -fsSL $idea_source -o /opt/idea/installer.tgz --create-dirs \
  && tar --strip-components=1 -xzf installer.tgz \
  && rm installer.tgz

RUN curl -L https://dl.bintray.com/groovy/maven/apache-groovy-binary-2.4.13.zip > /tmp/apache-groovy.zip \
  && unzip /tmp/apache-groovy.zip \
  && rm /tmp/apache-groovy.zip \
  && mv groovy-* groovy \
  && curl -L https://github.com/bentolor/idea-cli-inspector/archive/master.zip > /tmp/bentolor.zip \
  && unzip /tmp/bentolor.zip \
  && rm /tmp/bentolor.zip \
  && mv idea-cli-inspector-* idea-cli-inspector

ENV PATH="/home/ijinspector/groovy/bin:${PATH}"
ENV IDEA_HOME="/home/ijinspector/idea-IC"

COPY --chown=ijinspector:ijinspector jdk.table.xml /home/ijinspector/.IdeaIC2019.1/config/options/jdk.table.xml

#let's pre-create empty dirs for mounts created by the entrypoint script
RUN mkdir -p /home/ijinspector/idea-project-tmprw \
    && mkdir -p /home/ijinspector/idea-project \
    && mkdir -p /home/ijinspector/idea-project-overlay-workdir

# declare a VOLUME so that its filesystem is not of type overlay so that we can create an overlay in the entrypoint
VOLUME /home/ijinspector
WORKDIR /home/ijinspector/idea-project-tmprw
