#!/usr/bin/env bash

source ./common.sh
ns="simple-api-$(generate_random_string)"
echo "Testing Simple API Endpoint in namespace ${ns}"
endpoint="${ns}.${OPENSHIFT_PUBLIC_HOSTNAME}.nip.io"
oc new-project ${ns} &> /dev/null
./deploy_operator.sh ${ns}
oc new-app -f ./test_objects/endpoint.yaml --param HOSTNAME=${endpoint} -n ${ns} &> /dev/null
wait_for_pod_ready app apicast ${ns}
echo "Proxy deployed successfully in ${ns}"
# Verifying expected HTTPS status
result=$(do_http_get ${endpoint}"/hello" 10)
if [[ ${result} != *"10 200"* ]]; then
    echo "Error. Unexpected status code response for endpoint test "${result}
    exit 1
fi
echo -e "Endpoint test successful in ${ns}\n"