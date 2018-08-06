# "Ostia" Project main repository

Ostia aims to be an openshift native API Management software.

This is a not supported/official redhat product.

## Deployment

* To learn how to deploy openshift locally:

<https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md>

* Clone the repo:

```
git clone https://github.com/3scale/ostia.git
cd ostia
```

* Create the required objects, first the Custom Resource Definition:

```
oc create -f ostia-operator/deploy/crd.yaml
```

* Add cluster-admin perms to the ostia default user: (needs fix)

```
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:ostia:default
```

* Deploy the operator, you can create a new project for if:

```
oc new-project ostia
oc create -f ostia-operator/deploy/operator.yaml
```

* Deploy the example Custom Resource in any namespace:

```
oc new-project myhelloapi
oc create -f ostia-operator/deploy/cr.yaml
```

## Build

* Prerequisites:
  * Go >= 1.10
  * Go Dep (<https://github.com/golang/dep>)
  * Operator-SDK v0.0.5 (<https://github.com/operator-framework/operator-sdk>)
  * Docker

* Installing Go:

Please refer to the official docs: <https://golang.org/doc/install>

* Installing Go Dep:

Mac:

```
brew install dep
```

Other Platforms:

```
curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
```

* Get the Ostia code

```
go get github.com/3scale/ostia
```

* Run dep ensure

```
cd ${GOPATH}/src/github.com/3scale/ostia/ostia-operator
dep ensure -v
```

* Install operator-framework from vendored sources

```
go install ./vendor/github.com/operator-framework/operator-sdk/commands/operator-sdk
```

Make sure ${GOPATH}/bin is added to your PATH

* Build

```
make build
```

* Push

```
make push
```

## Testing

The `ostia-operator` project is configured to use [circleci](https://circleci.com) and there are a number of integration tests
which will run when a pull request is triggered against this repository.

Tests can be run locally but expect a running an accessible OpenShift cluster with an `nip.io` hostname.

Run integration tests via `make integration` which accepts an optional argument:
1. `OPENSHIFT_PUBLIC_HOSTNAME`. The public hostname for OpenShift cluster. Default `127.0.0.1`

The same tests are run against the `circleci` build server but because of the executor type required, cannot be executed locally via `circleci build`.
