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
docker run -p 8000:8000 <YOURNAME:YOURTAG> 
```
> NOTE: # Ports are your port number.

This ensures that your app itself is working and issues will not be caused by syntax or other issues.

### Step 1: Set environment variables

Setting the variables below will make entering commands a little faster and more consistent.

```bash
   RESOURCE_GROUP="<my-resource-group>"
   LOCATION="<westus>" # Change to your preferred [location](https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/?products=container-apps)
   ENVIRONMENT="acrenv"
   API_NAME="<my-api-name>"
   UNQIUE="<my-unique-characters>" # try to be unique to avoid conflicts
   ACR_NAME="<acaprojectname>"+$UNIQUE # must be all lowercase
   REGISTRY_SERVER=$ACR_NAME".azurecr.io"
   IMAGE_URI=$REGISTRY_SERVER"/"$API_NAME
```

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

REGISTRY_USERNAME=$ACR_NAME
REGISTRY_PASSWORD=$(az acr credential show \
   --name $ACR_NAME \
   --query passwords[0].value \
   --output tsv)

```
### Step 4: Build Your Container
```base
az acr build -t $IMAGE_URI . -r $ACR_NAME --platform linux/amd64` 

### Step 5: Create an ACA Environment
```bash
   --resource-group $RESOURCE_GROUP \
   --name $ENVIRONMENT \
   --location $LOCATION
```


### Step 6: Deploy Your Container to the Container App
```bash
   --registry-password $(az acr credential show --name $ACR_NAME --query passwords[0].value --output tsv)
az containerapp create \
   --resource-group $RESOURCE_GROUP \
   --name $API_NAME \
   --environment $ENVIRONMENT \
   --image $IMAGE_URI \
   --target-port '8000' \
   --ingress 'external' \
   --registry-server $REGISTRY_SERVER \
   --registry-username $REGISTRY_USERNAME \
   --registry-password $REGISTRY_PASSWORD

```