#!/bin/bash -x
set -o errexit

jenkins_default_parameters="-fsroot /opt/jenkins-swarm/ -disableSslVerification"

java_vm_parameters=""

if [ -n "${JAVA_VM_PARAMETERS}" ]; then
  java_vm_parameters=${JAVA_VM_PARAMETERS}
fi

jenkins_master="http://jenkins:8080"

if [ -n "${JENKINS_MASTER_URL}" ]; then
  jenkins_master=${JENKINS_MASTER_URL}
fi

jenkins_swarm_parameters=""

if [ -n "${SWARM_CLIENT_PARAMETERS}" ]; then
  jenkins_swarm_parameters=${SWARM_CLIENT_PARAMETERS}
fi

jenkins_user=""

if [ -n "${JENKINS_USER}" ] && [ -n "${JENKINS_PASSWORD}" ]; then
  jenkins_user="-username "${JENKINS_USER}" -password "${JENKINS_PASSWORD}
fi

jenkins_executors=""

if [ -n "${SWARM_CLIENT_EXECUTORS}" ]; then
  jenkins_executors="-executors "${SWARM_CLIENT_EXECUTORS}
fi

swarm_labels=""

if [ -n "${SWARM_CLIENT_LABELS}" ]; then
  swarm_labels="-labels '"${SWARM_CLIENT_LABELS}"'"
fi

if [ "$1" = 'swarm' ]; then
  runuser -l jenkins -c "${SWARM_JAVA_HOME}/bin/java -Dfile.encoding=UTF-8 ${java_vm_parameters} -jar /opt/jenkins-swarm/swarm-client-jar-with-dependencies.jar ${jenkins_default_parameters} -master ${jenkins_master} ${jenkins_executors} ${swarm_labels} ${jenkins_user} ${jenkins_swarm_parameters}"
fi

exec "$@"
