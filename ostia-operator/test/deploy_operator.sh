#!/usr/bin/env bash
NAMESPACE=${1}
source ./common.sh

echo "Deploying Operator in ${NAMESPACE}"
oc create -f ../deploy/rbac.yaml
oc create -f ../deploy/operator.yaml -n ${NAMESPACE}
wait_for_pod_ready name ostia-operator ${NAMESPACE}
echo -e "Operator deployed successfully in ${NAMESPACE}\n"