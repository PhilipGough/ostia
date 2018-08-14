#!/usr/bin/env bash

OPENSHIFT_PUBLIC_HOSTNAME=$1

[[ $(oc cluster status) =~ "not running" ]] && oc cluster up --public-hostname="${OPENSHIFT_PUBLIC_HOSTNAME}"

oc login -u system:admin --insecure-skip-tls-verify=true > /dev/null
oc adm policy add-cluster-role-to-user cluster-admin developer
oc login -u developer --insecure-skip-tls-verify=true > /dev/null
oc create -f ../deploy/crd.yaml &> /dev/null || true

