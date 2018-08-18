#!/usr/bin/env bash

if $(oc get pods > /dev/null 2>&1); then
    HOSTNAME_FROM_OC=$(basename $(oc whoami --show-server=true) | cut -f1 -d":")
fi

if [ -z "$OPENSHIFT_PUBLIC_HOSTNAME" ]; then
    export OPENSHIFT_PUBLIC_HOSTNAME=${HOSTNAME_FROM_OC}
fi

dir=$(pwd)

for f in ./tests/*-*/*.sh; do
  echo "Launching: $f"
  cd ${f%/*}; ./$(basename $f) &
  cd $dir
done

wait