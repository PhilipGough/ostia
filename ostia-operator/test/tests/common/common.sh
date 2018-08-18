#!/usr/bin/env bash


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
# Expects three args: Key and value filter for Pod metadata labels, Pod namespace
wait_for_pod_ready () {
 sleep 5 # Wait for Pod to be created before checking its readiness
 retries="12"
 while [[ "retries" -gt "0" ]]
 do
    if [ "$(oc get pod -o jsonpath='{.items[?(@.metadata.labels.'${1}'=="'${2}'")].status.containerStatuses[0].ready}' -n ${3} )" == "true" ];
    then
        return
    else
        let "retries--"
        sleep 10
    fi
 done
 echo "Pod was not ready in time"
 oc delete project ${3}
 exit 1
}

# Prints to stdout the number of each unique status codes
# Expects two args: Endpoint to make HTTP request against, number of requests to make
do_http_get() {
 for i in $(seq 1 ${2}); do
   curl -k -s -o /dev/null -w "%{http_code}\n" ${1};
 done | uniq -c

}

# Returns a random string of 8 chars
generate_random_string() {
 hexdump -n 8 -e '4/4 "%08X" 1 "\n"' /dev/random |  tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]'
}
