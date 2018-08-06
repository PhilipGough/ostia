NAME=ostia-operator
NAMESPACE=quay.io/3scale
VERSION := v0.1
IMAGE := $(NAMESPACE)/$(NAME):$(VERSION)
OPENSHIFT_PUBLIC_HOSTNAME := 127.0.0.1

all: generate build

generate:
	@operator-sdk generate k8s

build:
	@operator-sdk build $(IMAGE)

test: build
	@docker run -t $(IMAGE) ostia-operator

bash:
	docker run -it $(IMAGE) bash

push:
	docker push $(IMAGE)

integration:
	cd test && ./setup.sh ${OPENSHIFT_PUBLIC_HOSTNAME}
	cd test && ./integration.sh ${OPENSHIFT_PUBLIC_HOSTNAME}

