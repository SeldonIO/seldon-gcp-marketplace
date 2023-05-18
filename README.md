# GCP Marketplace deployer for Seldon Core

Provide scripts to create the GCP Marketplace installation for [Seldon Core](https://github.com/SeldonIO/seldon-core).

## Steps to Update

To update the market place for a new release of Seldon Core.

 1. Update the chart and test
 1. Update the images in the release project
 1. Inform google of update via control panel and email

Estimated time: 1-2 hours.

### Update Chart and Test

Update the Makefile to fetch the latest helm chart by changing the CHART_VERSION

```
TAG ?= 1.7
CHART_VERSION ?= 1.7.0
PULL_TAG ?= 1.7.0
```

For GCP if there is a change in TAG (i.e. not a semver bugfix update 1.2.1 -> 1.2.3) then this will be a new TAG in GCP as opposed to an update to an existing TAG.


Run

```
make update-chart
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
   * We use the `klaw-project` project by default
   * Make sure you are authenticated (`gcloud auth login`)
   * You can set it with `gcloud config set project seldon-demos`
   * You can check its set with `gcloud config get-value project`


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

To deploy and verify via creating a model as described in apptest chart run

```
make verify
```

**Update licenses by following [license README](./licenses/README.md)**

## Publish

Make sure the spreadsheets are updated:

* [Executor Spreadsheet](https://docs.google.com/spreadsheets/d/1RFG4TqzipdV8GTpWl8O3lZfc7uvb2h3jftcBL62knrE/edit#gid=1834865489)
* [Operator Spreadsheet](https://docs.google.com/spreadsheets/d/1aRZotyw9rqdMafUhh8_YrSA7uXQyvygGP9wtFD1C1zI/edit#gid=213073333)

Build and push images to the staging project

```
gcloud config set project seldon-core-public
```

Build and push all images again. They will be built and tag with the new project repo and pushed.

```
make build_all push_all
```

Go to [portal](https://console.cloud.google.com/partner/editor/seldon-portal/seldon-core?project=seldon-portal&folder&organizationId=156002945562) to update the version.

May also need to send email to googlemarketplaceonboarding@google.com

