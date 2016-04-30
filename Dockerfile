FROM blacklabelops/java:centos.jre8
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

# Jenkins Swarm Version
ARG SWARM_VERSION=2.0
# Container User
ARG CONTAINER_USER=swarmslave
ARG CONTAINER_UID=1000
ARG CONTAINER_GROUP=swarmslave
ARG CONTAINER_GID=1000

# Container Internal Environment Variables
ENV SWARM_HOME=/opt/jenkins-swarm \
    SWARM_JAVA_HOME=/opt/java/jre${JAVA_VERSION} \
    SWARM_WORKDIR=/opt/jenkins

RUN /usr/sbin/groupadd --gid $CONTAINER_GID $CONTAINER_GROUP && \
    /usr/sbin/useradd --uid $CONTAINER_UID --gid $CONTAINER_GID --shell /bin/bash $CONTAINER_USER && \
    # Install Development Tools
    yum install -y \
        wget \
        tar \
        gzip \
        svn \
        mercurial \
        git && \
    yum clean all && rm -rf /var/cache/yum/* && \
    # Install Git-LFS
    export GIT_LFS_VERSION=1.1.2 && \
    wget -O /tmp/git-lfs-linux-amd64.tar.gz https://github.com/github/git-lfs/releases/download/v${GIT_LFS_VERSION}/git-lfs-linux-amd64-${GIT_LFS_VERSION}.tar.gz && \
    tar xfv /tmp/git-lfs-linux-amd64.tar.gz -C /tmp && \
    cd /tmp/git-lfs-${GIT_LFS_VERSION}/ && bash -c "/tmp/git-lfs-${GIT_LFS_VERSION}/install.sh" && \
    git lfs install && \
    # Install Tini Zombie Reaper And Signal Forwarder
    export TINI_VERSION=0.9.0 && \
    export TINI_SHA=fa23d1e20732501c3bb8eeeca423c89ac80ed452 && \
    curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static -o /bin/tini && \
    chmod +x /bin/tini && \
    echo "$TINI_SHA /bin/tini" | sha1sum -c - && \
    # Install Jenkins Swarm-Slave
    mkdir -p ${SWARM_HOME} && \
    wget --directory-prefix=${SWARM_HOME} \
      http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}-jar-with-dependencies.jar  && \
    mv ${SWARM_HOME}/swarm-client-${SWARM_VERSION}-jar-with-dependencies.jar ${SWARM_HOME}/swarm-client-jar-with-dependencies.jar && \
    mkdir -p ${SWARM_WORKDIR} && \
    chown -R ${CONTAINER_USER}:${CONTAINER_GROUP} ${SWARM_HOME} ${SWARM_WORKDIR} && \
    chmod +x ${SWARM_HOME}/swarm-client-jar-with-dependencies.jar

# Entrypoint Environment Variables
ENV SWARM_VM_PARAMETERS= \
    SWARM_MASTER_URL= \
    SWARM_VM_PARAMETERS= \
    SWARM_JENKINS_USER= \
    SWARM_JENKINS_PASSWORD= \
    SWARM_CLIENT_EXECUTORS= \
    SWARM_CLIENT_LABELS= \
    SWARM_CLIENT_NAME=

USER $CONTAINER_USER
WORKDIR $SWARM_WORKDIR
VOLUME $SWARM_WORKDIR
COPY imagescripts/docker-entrypoint.sh ${SWARM_HOME}/docker-entrypoint.sh
ENTRYPOINT ["/bin/tini","--","/opt/jenkins-swarm/docker-entrypoint.sh"]
CMD ["swarm"]
