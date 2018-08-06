#!/usr/bin/env bash

OPENSHIFT_PUBLIC_HOSTNAME=${1}

# Check if namespace exists
# Arg: Project name
project_exists () {
  oc get project $1 &> /dev/null
}

# Delete namespace if it exists
# Arg: Project name
delete_project_and_wait () {
  if project_exists $1; then
    echo "Cleaning up project" ${1}
    oc delete project ${1} --now=true
    while project_exists ${1}
    do
        sleep 3
    done
   fi
}

# Give Pods two minutes to hit ready status before error
# Expects two args: Key and value filter for Pod metadata labels
wait_for_pod_ready () {
 sleep 3 # Wait for Pod to be created before checking its readiness
 retries="12"
 while [[ "retries" -gt "0" ]]
 do
    if "$(oc get pod -o jsonpath='{.items[?(@.metadata.labels.'${1}'=="'${2}'")].status.containerStatuses[0].ready}')" == "true"
    then
        return
    else
        let "retries--"
        sleep 10
    fi
 done
 echo "Pod was not ready in time"
 exit 1
}

# Prints to stdout the number of each unique status codes
# Expects two args: Endpoint to make HTTP request against, number of requests to make
do_http_get() {
for i in $(seq 1 ${2}); do
 curl -k -s -o /dev/null -w "%{http_code}\n" ${1};
done | uniq -c

}

echo "Testing Operator Deployment"
# Tear down operator project
delete_project_and_wait ostia
# Create Operator project
oc new-project ostia &> /dev/null
oc create -f ../deploy/operator.yaml
# Wait for Pod readiness
wait_for_pod_ready name ostia-operator
echo -e "Operator deployed successfully\n"


echo "Testing Simple API Endpoint"
endpoint="simple-api-endpoint.${OPENSHIFT_PUBLIC_HOSTNAME}.nip.io"
# Tear down project
delete_project_and_wait simple-api-endpoint
oc new-project simple-api-endpoint &> /dev/null
oc new-app -f ./test_objects/endpoint.yaml --param HOSTNAME=${endpoint} &> /dev/null
wait_for_pod_ready app apicast
echo "Proxy deployed successfully"
# Verifying expected HTTPS status
result=$(do_http_get ${endpoint}"/hello" 10)
if [[ ${result} != *"10 200"* ]]; then
    echo "Error. Unexpected status code response for endpoint test "${result}
    exit 1
fi
echo -e "Endpoint test successful\n"
