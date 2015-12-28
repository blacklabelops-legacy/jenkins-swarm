FROM blacklabelops/java-jdk-8
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

# Propert permissions
ENV CONTAINER_USER jenkins
ENV CONTAINER_UID 1000
ENV CONTAINER_GROUP jenkins
ENV CONTAINER_GID 1000

RUN /usr/sbin/groupadd --gid $CONTAINER_GID jenkins && \
    /usr/sbin/useradd --uid $CONTAINER_UID --gid $CONTAINER_GID --create-home --shell /bin/bash jenkins

# install dev tools
RUN yum install -y \
    svn \
    mercurial \
    git && \
    yum clean all && rm -rf /var/cache/yum/*

# install git-lfs
ENV GIT_LFS_VERSION=1.1.0
RUN wget --no-check-certificate -O /tmp/git-lfs-linux-amd64.tar.gz https://github.com/github/git-lfs/releases/download/v${GIT_LFS_VERSION}/git-lfs-linux-amd64-${GIT_LFS_VERSION}.tar.gz && \
    tar xfv /tmp/git-lfs-linux-amd64.tar.gz -C /tmp && \
    cd /tmp/git-lfs-${GIT_LFS_VERSION}/ && bash -c "/tmp/git-lfs-${GIT_LFS_VERSION}/install.sh" && \
    git lfs init

# install swarm-slave
ENV SWARM_HOME /home/jenkins
ENV SWARM_JAVA_HOME=/opt/java/jdk${JAVA_VERSION}
ENV SWARM_VERSION 2.0
RUN wget --no-check-certificate --directory-prefix=${SWARM_HOME} \
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

USER $CONTAINER_UID
WORKDIR /home/jenkins
COPY imagescripts/docker-entrypoint.sh /home/jenkins/docker-entrypoint.sh
ENTRYPOINT ["/home/jenkins/docker-entrypoint.sh"]
CMD ["swarm"]
