#!/bin/bash

set -o errexit

if [ -n "${SWARM_DELAYED_START}" ]; then
  sleep ${SWARM_DELAYED_START}
fi

if [ -n "${SWARM_ENV_FILE}" ]; then
  source ${SWARM_ENV_FILE}
fi

jenkins_default_parameters="-disableSslVerification"

java_vm_parameters=""

if [ -n "${SWARM_VM_PARAMETERS}" ]; then
  java_vm_parameters=${SWARM_VM_PARAMETERS}
fi

jenkins_master="http://jenkins:8080"

if [ -n "${SWARM_MASTER_URL}" ]; then
  jenkins_master=${SWARM_MASTER_URL}
fi

jenkins_swarm_parameters=""

if [ -n "${SWARM_CLIENT_PARAMETERS}" ]; then
  jenkins_swarm_parameters=${SWARM_CLIENT_PARAMETERS}
fi

jenkins_user=""

if [ -n "${SWARM_JENKINS_USER}" ] && [ -n "${SWARM_JENKINS_PASSWORD}" ]; then
  jenkins_user="-username "${SWARM_JENKINS_USER}" -password "${SWARM_JENKINS_PASSWORD}
fi

jenkins_executors=""

if [ -n "${SWARM_CLIENT_EXECUTORS}" ]; then
  jenkins_executors="-executors "${SWARM_CLIENT_EXECUTORS}
fi

swarm_labels=""

if [ -n "${SWARM_CLIENT_LABELS}" ]; then
  swarm_labels="-labels '"${SWARM_CLIENT_LABELS}"'"
fi

unset SWARM_JENKINS_USER
unset SWARM_JENKINS_PASSWORD
unset SWARM_MASTER_URL

jenkins_workdir="-fsroot ${SWARM_WORKDIR}"

if [ "$1" = 'swarm' ]; then
  # Run the Swarm-Client according to environment variables.
  exec ${SWARM_JAVA_HOME}/bin/java -Dfile.encoding=UTF-8 ${java_vm_parameters} -jar ${SWARM_HOME}/swarm-client-jar-with-dependencies.jar ${jenkins_default_parameters} -master ${jenkins_master} ${jenkins_executors} ${swarm_labels} ${jenkins_user} ${jenkins_swarm_parameters} ${jenkins_workdir}
fi
if [[ "$1" == '-'* ]]; then
  # Run the Swarm-Client with passed parameters.
  exec java ${java_vm_parameters} -jar ${SWARM_HOME}/swarm-client-jar-with-dependencies.jar "$@"
fi

exec "$@"
