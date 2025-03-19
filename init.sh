#!/bin/bash

# Define the environment variables needed for Azure authentication
# AZURE_CLIENT_ID="<your-client-id>"
# AZURE_CLIENT_SECRET="<your-client-secret>"
# AZURE_TENANT_ID="<your-tenant-id>"
# AZURE_SUBSCRIPTION_ID="<your-subscription-id>"

# TF_STATE_RG="<your-resource-group>"
# TF_STATE_STORAGE="<your-storage-account>"
# TF_STATE_CONTAINER="<your-container-name>"

# Login to Azure using service principal
echo "Logging into Azure using service principal..."
az login --service-principal -u "$AZURE_CLIENT_ID" -p "$AZURE_CLIENT_SECRET" --tenant "$AZURE_TENANT_ID" --allow-no-subscriptions

# Check if the storage account exists
storageAccountExists=$(az storage account show --name "$TF_STATE_STORAGE" --resource-group "$TF_STATE_RG" --query id -o tsv || echo "not found")

if [ "$storageAccountExists" == "not found" ]; then
    echo "Creating new storage account for Terraform state."

    # Create resource group if it does not exist
    az group create --name "$TF_STATE_RG" --location eastus || true

    # Create storage account
    az storage account create --name "$TF_STATE_STORAGE" --resource-group "$TF_STATE_RG" --sku Standard_LRS

    # Wait for the storage account to be created
    sleep 30

    # Get the storage account key
    accountKey=$(az storage account keys list --account-name "$TF_STATE_STORAGE" --resource-group "$TF_STATE_RG" --query "[0].value" -o tsv)

    # Create the container for Terraform state
    az storage container create --name "$TF_STATE_CONTAINER" --account-name "$TF_STATE_STORAGE" --account-key "$accountKey"
else
    echo "Terraform state storage already exists. Skipping creation."
fi
