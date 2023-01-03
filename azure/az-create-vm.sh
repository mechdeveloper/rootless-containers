#!/bin/bash

RESOURCE_GROUP="RG-ROOTLESS-PODMAN"
VM_NAME="VM-RHEL-C6BU9F"
VM_IMAGE="RedHat:RHEL:8_7:8.7.2022112201"
VM_USERNAME="azureuser"

B_RG_EXISTS=$(az group exists -n $RESOURCE_GROUP)

if [[ $B_RG_EXISTS ]]
then 
  echo "Resource Group $RESOURCE_GROUP exists"
fi

# Remove Resource Group
az group delete --name $RESOURCE_GROUP

# Create Resource Group
echo "Creating new Resource Group"
az group create --name $RESOURCE_GROUP --location westeurope

# Create VM 
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image $VM_IMAGE \
  --admin-username $VM_USERNAME \
  --generate-ssh-keys

# Upload SSH Key
az sshkey create --name "azureuserSSHKey" --public-key "~/.ssh/id_rsa.pub" --resource-group $RESOURCE_GROUP

VM_PUBLIC_IP=$(az vm list-ip-addresses -g $RESOURCE_GROUP -n $VM_NAME --query "[].virtualMachine.network.publicIpAddresses[].ipAddress" -o tsv)

# Print SSH Command
echo -e "VM Available Login using \n \n \t ssh $VM_USERNAME@$VM_PUBLIC_IP"