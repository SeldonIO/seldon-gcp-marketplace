SHELL=/bin/bash

TAG ?= 1.14
CHART_VERSION ?= 1.14.1
PULL_TAG ?= 1.14.1

APP_NAME=seldon-core
REGISTRY=gcr.io/$(shell gcloud config get-value project | tr ':' '/')

.PHONY: update-chart
update-chart:
	rm -rf chart
	mkdir chart
	helm fetch --untar --destination chart --repo https://storage.googleapis.com/seldon-charts --version ${CHART_VERSION} seldon-core-operator --devel
	rmdir chart/seldon-core-operator-${CHART_VERSION}.tgz/
	python scripts/update_helm_chart.py
	helm template chart/seldon-core-operator --set rbac.create=true > template.yaml && python scripts/update_schema.py && rm template.yaml
	cp resources/application.yaml chart/seldon-core-operator/templates

check:
	./scripts/mpdev.sh /scripts/doctor

#test-install:
#	kubectl create namespace test-ns
#	./scripts/mpdev.sh /scripts/install \
#		--deployer=$REGISTRY/$APP_NAME/deployer \
#		--parameters='{"name": "test-deployment", "namespace": "test-ns"}'

install-application-crd:
	kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"

create-test-ns:
	kubectl create ns test-ns || echo "namespace test-ns exists"

deploy: create-test-ns
	./scripts/mpdev.sh /scripts/install \
		--deployer=${REGISTRY}/seldonio/${APP_NAME}/deployer:${TAG} \
		--parameters='{"name": "test-deployment", "namespace": "test-ns", "operatorImage": "'$(REGISTRY)/seldonio/${APP_NAME}:$(PULL_TAG)'", "executorImage":"'$(REGISTRY)/seldonio/${APP_NAME}/seldon-core-executor:$(PULL_TAG)'"}'

# There is no automated undeploy available after a deploy.
undeploy:
	kubectl delete application test-deployment -n test-ns --ignore-not-found=true
	kubectl delete statefulset seldon-operator-controller-manager -n test-ns --ignore-not-found=true
	kubectl delete service webhook-server-service -n test-ns --ignore-not-found=true
	kubectl delete secret seldon-operator-webhook-server-secret -n test-ns --ignore-not-found=true
	kubectl delete crd seldondeployments.machinelearning.seldon.io --ignore-not-found=true

verify:
	./scripts/mpdev.sh /scripts/verify \
		--deployer=${REGISTRY}/seldonio/${APP_NAME}/deployer:${TAG} \
		--parameters='{"name": "test-deployment", "namespace": "test-ns", "operatorImage": "'$(REGISTRY)/seldonio/${APP_NAME}:$(PULL_TAG)'", "executorImage":"'$(REGISTRY)/seldonio/${APP_NAME}/seldon-core-executor:$(PULL_TAG)'"}'


#
# Images
#

build_deployer:
	docker build \
	--build-arg REGISTRY="$(REGISTRY)/seldonio" \
	--build-arg TAG="$(PULL_TAG)" \
	--tag ${REGISTRY}/seldonio/${APP_NAME}/deployer:${TAG} .

push_deployer:
	docker push ${REGISTRY}/seldonio/${APP_NAME}/deployer:${TAG}

build_operator: 
	docker pull seldonio/seldon-core-operator:$(PULL_TAG)
	docker tag seldonio/seldon-core-operator:$(PULL_TAG) "$(REGISTRY)/seldonio/${APP_NAME}:$(PULL_TAG)"
	docker tag seldonio/seldon-core-operator:$(PULL_TAG) "$(REGISTRY)/seldonio/${APP_NAME}:$(TAG)"

push_operator:
	docker push "$(REGISTRY)/seldonio/${APP_NAME}:$(PULL_TAG)"
	docker push "$(REGISTRY)/seldonio/${APP_NAME}:$(TAG)"

build_executor:
	docker pull seldonio/seldon-core-executor:$(PULL_TAG)
	docker tag seldonio/seldon-core-executor:$(PULL_TAG) "$(REGISTRY)/seldonio/${APP_NAME}/seldon-core-executor:$(PULL_TAG)"
	docker tag seldonio/seldon-core-executor:$(PULL_TAG) "$(REGISTRY)/seldonio/${APP_NAME}/seldon-core-executor:$(TAG)"

push_executor:
	docker push "$(REGISTRY)/seldonio/${APP_NAME}/seldon-core-executor:$(PULL_TAG)"
	docker push "$(REGISTRY)/seldonio/${APP_NAME}/seldon-core-executor:$(TAG)"

build_tester:
	docker pull cfmanteiga/alpine-bash-curl-jq
	docker tag cfmanteiga/alpine-bash-curl-jq "$(REGISTRY)/seldonio/tester:$(PULL_TAG)"
	docker tag cfmanteiga/alpine-bash-curl-jq "$(REGISTRY)/seldonio/tester:$(TAG)"

push_tester:
	docker push "$(REGISTRY)/seldonio/tester:$(PULL_TAG)"
	docker push "$(REGISTRY)/seldonio/tester:$(TAG)"

build_all: build_deployer build_operator build_executor build_tester
push_all: push_deployer push_operator push_executor push_tester

test: update-chart build_all push_all verify

clean:
	rm -rf chart

install-k8s-applications-resource:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/application/master/deploy/kube-app-manager-aio.yaml
