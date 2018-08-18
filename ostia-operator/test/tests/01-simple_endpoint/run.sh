#!/usr/bin/env bash -e

source ../common/common.sh

ns="simple-api-$(generate_random_string)"
endpoint="${ns}.${OPENSHIFT_PUBLIC_HOSTNAME}"

echo "Testing Simple API Endpoint in namespace ${ns}"

oc new-project ${ns} > /dev/null

../common/deploy_operator.sh ${ns}

oc new-app -f ../common/echo_api.yaml -n ${ns} >/dev/null

wait_for_pod_ready app echo-api ${ns}

echo "echo-api deployed in ${ns}"

oc new-app -f ./endpoint.yaml --param HOSTNAME=${endpoint} -n ${ns} >/dev/null

wait_for_pod_ready app apicast ${ns}

echo "Proxy deployed successfully in ${ns}"

# Verifying expected HTTPS status

result=$(do_http_get ${endpoint}"/hello" 10)

# Cleanup
oc delete project ${ns}

if [[ ${result} != *"10 200"* ]]; then
    echo "Error. Unexpected status code response for endpoint test "${result}
    exit 1
fi

echo -e "Endpoint test successful in ${ns}\n"
