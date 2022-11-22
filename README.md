# Add Simple Flask App to Azure via Azure Container Services and Azure Container Registry (ACA)

This repo walks you through the steps to deploy a simple hello world flask app (NoDB) to [Azure Container Services (ACS)](https://learn.microsoft.com/en-us/azure/container-apps/overview) using the Azure Developer CLI.

## System Prerequisites

* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Docker](https://docs.docker.com/install/)

## QuickStart (Deploy this Project) Estimated time: 8 minutes

The instructions to build this project are heavily inspired by [Quickstart: Deploy your code to Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/quickstart-code-to-cloud?tabs=bash%2Cpython&pivots=docker-local)

If you want to deploy this project to Azure, follow these steps:

#### Instructions

`text in code blocks` are commands that you should enter into your terminal.

`<Replace text in Brackets>` with your own values. Follow the casing and spacing of the example:

* `<ALLCAPS>`
* `<lowercase>`
* `<kebab-case>`

follow the guidance in the comments `foo # follow these notes`
### [OPTIONAL] Step 0: Ensure your container builds locally

```bash
docker build -t <yourname:yourtag> .
docker run -p <EXTERNALPORT:INTERNALPORT YOURNAME:YOURTAG> 
```
> NOTE: # Ports are your port number 5000:5000 by default.

This ensures that your app itself is working and issues will not be caused by syntax or other issues.

### Step 1: Set environment variables

Setting the variables below will make entering commands a little faster and more consistent.

   1. `RESOURCE_GROUP="<my-resource-group>"`
   2. `LOCATION="<westus>"` # Change to your preferred [location](https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/?products=container-apps)
   3. `ENVIRONMENT="<my-environment>"`
   4. `API_NAME="<my-api-name>"`
   5. `UNQIUE="<my-unique-characters>"` # try to be unique to avoid conflicts
   `ACR_NAME="acaprojectname"+$UNIQUE` # must be all lowercase
   6. `REGISTRY_SERVER=$ACR_NAME".azurecr.io"`
   7. `IMAGE_URI=$ACR/$API_NAME`
### Step 2: Create A Resource Group
```bash
az group create \
--name $RESOURCE_GROUP \
--location $LOCATION
```

### Step 3: Create a Container Registry

```bash
az acr create \
   --resource-group $RESOURCE_GROUP \
   --name $ACR_NAME \
   --sku Basic \
   --admin-enabled true
```
### Step 4: Build Your Container
`docker build -t $REGISTRY_SERVER . --platform linux/amd64`

### Step 5: Login into the Azure Container Registry
`az acr login --name $REGISTRY_SERVER`

### Step 6: Push your container to the Azure Container Registry
`docker push $IMAGE_URL`
### Step 7: Create an ACA Environment
`az containerapp env create --resource-group $RESOURCE_GROUP --name $ENVIRONMENT --location $LOCATION`

### Step 6: Deploy Your Container to the Container App
```bash
az containerapp create \
--resource-group $RESOURCE_GROUP \
--name $API_NAME \
--environment $ENVIRONMENT \
--image $IMAGE_URI \
--target-port <INTERNALPORT> \
--ingress 'external' \
--registry-server $REGISTRY_SERVER \
```