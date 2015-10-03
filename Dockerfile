FROM blacklabelops/java-jdk-8
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

# install dev tools
RUN yum install -y \
    svn \
    mercurial \
    git && \
    yum clean all && rm -rf /var/cache/yum/*

# install swarm-slave
ENV SWARM_HOME /opt/jenkins-swarm
ENV SWARM_JAVA_HOME=/opt/java/jdk${JAVA_VERSION}
ENV SWARM_VERSION 2.0
RUN /usr/sbin/groupadd jenkins && \
    echo "%jira ALL=NOPASSWD: /usr/local/bin/own-volume" >> /etc/sudoers && \
    mkdir -p ${SWARM_HOME} && \
    /usr/sbin/useradd --create-home --home-dir ${SWARM_HOME} -g jenkins --shell /bin/bash jenkins && \
    wget --no-check-certificate --directory-prefix=${SWARM_HOME} \
      http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}-jar-with-dependencies.jar  && \
    mv ${SWARM_HOME}/swarm-client-${SWARM_VERSION}-jar-with-dependencies.jar ${SWARM_HOME}/swarm-client-jar-with-dependencies.jar && \
    chown -R jenkins:jenkins ${SWARM_HOME} && \
    chmod +x ${SWARM_HOME}/swarm-client-jar-with-dependencies.jar

# docker entrypoint env variables
ENV JAVA_VM_PARAMETERS=
ENV JENKINS_MASTER_URL=
ENV SWARM_CLIENT_PARAMETERS=
ENV JENKINS_USER=
ENV JENKINS_PASSWORD=
ENV SWARM_CLIENT_EXECUTORS=
ENV SWARM_CLIENT_LABELS=

WORKDIR /opt/jenkins-swarm
COPY imagescripts/docker-entrypoint.sh /opt/jenkins-swarm/docker-entrypoint.sh
ENTRYPOINT ["/opt/jenkins-swarm/docker-entrypoint.sh"]
CMD ["swarm"]
