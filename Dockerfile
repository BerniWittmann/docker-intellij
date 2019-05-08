FROM openjdk:8u151-jdk

LABEL maintainer "Bernhard Wittmann <dev@bernhardwittmann.com>"

RUN  \
  apt-get update && apt-get install --no-install-recommends -y \
  gcc git openssh-client less \
  libxtst-dev libxext-dev libxrender-dev libfreetype6-dev \
  libfontconfig1 libgtk2.0-0 libxslt1.1 libxxf86vm1 \
  && rm -rf /var/lib/apt/lists/* \
  && useradd -ms /bin/bash developer

ARG idea_source=https://download.jetbrains.com/idea/ideaIC-2019.1.1.tar.gz
ARG idea_local_dir=.IdeaIC2019.1

WORKDIR /opt/idea

RUN curl -fsSL $idea_source -o /opt/idea/installer.tgz \
  && tar --strip-components=1 -xzf installer.tgz \
  && rm installer.tgz

USER developer
ENV HOME /home/developer

COPY --chown=developer jdk.table.xml /home/developer/$idea_local_dir/config/options/jdk.table.xml

RUN mkdir /home/developer/.Idea \
&& ln -sf /home/developer/.Idea /home/developer/$idea_local_dir
