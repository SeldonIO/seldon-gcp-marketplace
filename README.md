# GCP Marketplace deployer for Seldon Core

Provide scripts to create the GCP Marketplace installation for [Seldon Core](https://github.com/SeldonIO/seldon-core).

## Steps to Update

To update the market place for a new release of Seldon Core.

 1. Update the chart and test
 1. Update the images in the release project
 1. Inform google of update via control panel and email

### Update Chart and Test

Update the Makefile to fetch the latest helm chart by changing the CHART_VERSION

```
CHART_VERSION ?= 1.2.1
```

Run

```
make update_chart
```

This will

 1. Download and extract chart
 1. Update the chart values to set some settings needed via `/scripts/update_helm_chart.py`
     1. No rbac create
     1. Manager must create resources including CRD
 1. Create a template from the chart with rbac set to true
 1. Try to extract the Role and ClusterRole from the template and update the schema.yaml to ensure the deployed app gets the correct RBAC. Google does not allow a helm chart to create RBAC itself. This is done via `/scripts/update_schema.py`
 1. cp the application.yaml into the chart.

Some issue that might happen:

  * RBAC is not been excluded or extracted correctly
  * Chart values have changed


Next build all the images. For this you will need:

 * A kubernetes cluster connected with kubectl access
 * An active GCP project, e.g.
   * `gcloud config configurations activate seldon-demos`


Change the PULL_TAG and TAG setttings for the new release:

  * PULL_TAG - the tag to pull seldon images
  * TAG - the tag for the GCP release

Run

Update licenses see [here](licenses/README.md).

```
make build_all push_all
```

Create a GKE cluster.

Install application CRD

```
make install-application-crd
```

To test the deployer succeeds run

```
make deploy
```

To remove the artifacts run

```
make undeploy
```

To dpeloy and verify via creating a model as described in apptest chart run

```
make verify
```

## Publish

Build and push images to the staging project

```
gcloud config configurations activate seldon-core-public
```

Build and push all images again. They will be built and tag with the new project repo and pushed.

```
make build_all push_all
```

Go to [portal](https://console.cloud.google.com/partner/editor/seldon-portal/seldon-core?project=seldon-portal&folder&organizationId=156002945562) to update the version.

May also need to send email to googlemarketplaceonboarding@google.com

