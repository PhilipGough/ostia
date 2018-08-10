#!/usr/bin/env bash
NAMESPACE=${1}
source ./common.sh

echo "Deploying Operator in ${NAMESPACE}"
oc new-app -f ../deploy/operator.yaml -e NAMESPACE=${NAMESPACE} -n ${NAMESPACE}
wait_for_pod_ready name ostia-operator ${NAMESPACE}
echo -e "Operator deployed successfully in ${NAMESPACE}\n"