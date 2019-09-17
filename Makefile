
# Load env variables from .env - https://unix.stackexchange.com/a/235254
include .env
export $(shell sed 's/=.*//' .env)

VERSION=1.15.3-2

.PHONY: all push manifests

check:
ifndef ECR_REPO
	$(error ECR_REPO needs to be set in .env file)
endif


all: check .
	docker build -t $(ECR_REPO):$(VERSION) .

manifests: check
	# ref https://github.com/helm/helm/blob/master/docs/using_helm.md#the-format-and-limitations-of---set
	helm template deploy/chart -n kube-node-lifecycle-labeller --namespace admin --set nodeSelector."kops\.k8s\.io/instancegroup"=nodes-spot --set  image.repository=$(ECR_REPO) --set  image.tag=$(VERSION) --output-dir deploy/manifests/
	mv deploy/manifests/kube-node-lifecycle-labeller/templates/* deploy/manifests/ 
	rm -rf deploy/manifests/kube-node-lifecycle-labeller

push: check .
	docker push $(ECR_REPO):$(VERSION)
