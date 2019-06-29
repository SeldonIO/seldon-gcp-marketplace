SHELL=/bin/bash

TAG ?= 0.3
PULL_TAG ?= 0.3.1

APP_NAME=seldon-core
REGISTRY=gcr.io/$(shell gcloud config get-value project | tr ':' '/')

.PHONY: update-chart
update-chart:
	rm -rf chart
	mkdir chart
	helm fetch --untar --destination chart --repo https://storage.googleapis.com/seldon-charts --version 0.3.1 seldon-core-operator
	python scripts/update_helm_chart.py
	cp resources/application.yaml chart/seldon-core-operator/templates
	cp resources/machinelearning_v1alpha2_seldondeployment.yaml chart/seldon-core-operator/templates
	rm chart/seldon-core-operator/templates/_hpa-spec-validation.tpl
	rm chart/seldon-core-operator/templates/_pod-spec-validation.tpl
	rm chart/seldon-core-operator/templates/_object-meta-validation.tpl
	rm chart/seldon-core-operator/templates/seldon-deployment-crd.json


install-application-crd:
	kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"

deploy:
	export MARKETPLACE_TOOLS_TAG=0.8.0 && mpdev /scripts/install \
		--deployer=${REGISTRY}/seldonio/${APP_NAME}/deployer:${TAG} \
		--parameters='{"name": "test-deployment", "namespace": "test-ns", "operatorImage": "gcr.io/seldon-demos/seldonio/seldon-core:0.3", "engineImage":"gcr.io/seldon-demos/seldonio/seldon-core/engine:0.3"}'

# There is no automated undeploy available after a deploy.
undeploy:
	kubectl delete application test-deployment -n test-ns --ignore-not-found=true
	kubectl delete statefulset seldon-operator-controller-manager -n test-ns --ignore-not-found=true
	kubectl delete service webhook-server-service -n test-ns --ignore-not-found=true
	kubectl delete secret seldon-operator-webhook-server-secret -n test-ns --ignore-not-found=true

verify:
	export MARKETPLACE_TOOLS_TAG=0.8.0 && mpdev /scripts/verify \
		--additional_deployer_role=cluster-admin \
		--deployer=${REGISTRY}/seldonio/${APP_NAME}/deployer:${TAG} \
		--parameters='{"name": "test-deployment", "namespace": "test-ns", "operatorImage": "gcr.io/seldon-demos/seldonio/seldon-core:0.3", "engineImage":"gcr.io/seldon-demos/seldonio/seldon-core/engine:0.3"}'


#
# Images
#

build_deployer:
	docker build --tag ${REGISTRY}/seldonio/${APP_NAME}/deployer:${TAG} .

push_deployer:
	docker push ${REGISTRY}/seldonio/${APP_NAME}/deployer:${TAG}

build_operator: 
	docker pull seldonio/seldon-core-operator:$(PULL_TAG)
	docker tag seldonio/seldon-core-operator:$(PULL_TAG) "$(REGISTRY)/seldonio/${APP_NAME}:$(TAG)"

push_operator:
	docker push "$(REGISTRY)/seldonio/${APP_NAME}:$(TAG)"

build_engine:
	docker pull seldonio/engine:$(PULL_TAG)
	docker tag seldonio/engine:$(PULL_TAG) "$(REGISTRY)/seldonio/${APP_NAME}/engine:$(TAG)"

push_engine:
	docker push "$(REGISTRY)/seldonio/${APP_NAME}/engine:$(TAG)"

build_all: build_deployer build_operator build_engine
push_all: push_deployer push_operator push_engine

test: update-chart build_all push_all verify

clean:
	rm -rf chart
