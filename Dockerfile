FROM openjdk:8u151-jdk

LABEL maintainer "Bernhard Wittmann <dev@bernhardwittmann.com>"

RUN  \
  apt-get update && apt-get install --no-install-recommends -y \
  gcc git openssh-client less \
  libxtst-dev libxext-dev libxrender-dev libfreetype6-dev \
  libfontconfig1 libgtk2.0-0 libxslt1.1 libxxf86vm1 \
  && rm -rf /var/lib/apt/lists/*

ARG idea_source=https://download.jetbrains.com/idea/ideaIC-2019.1.1.tar.gz
ARG idea_local_dir=.IdeaIC2019.1

WORKDIR /opt/idea

RUN curl -fsSL $idea_source -o /opt/idea/installer.tgz \
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

RUN groupadd -r ijinspector && useradd --no-log-init --gid ijinspector --home-dir /home/ijinspector --create-home ijinspector

USER ijinspector:ijinspector

WORKDIR /home/ijinspector

COPY --chown=ijinspector:ijinspector jdk.table.xml /home/ijinspector/$idea_local_dir/config/options/jdk.table.xml
COPY --chown=ijinspector:ijinspector jdk.table.xml /opt/idea/config/options/jdk.table.xml

RUN mkdir /home/ijinspector/.Idea \
  && ln -sf /home/ijinspector/.Idea /home/ijinspector/$idea_local_dir

USER root
