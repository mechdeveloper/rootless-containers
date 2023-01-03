# Create RedHat VM in azure

# Login using Service Principal

```
read -sp "Azure password: " AZ_PASS && echo && az login --service-principal -u $AZURE_CLIENT_ID -p $AZ_PASS --tenant $AZURE_TENANT
```

## List Images

```
az vm image list --publisher RedHat --all -o table
```

```
RESOURCE_GROUP="RG-ROOTLESS-PODMAN"
VM_NAME="VM-RHEL-C6BU9F"
VM_IMAGE="RedHat:RHEL:8_7:8.7.2022112201"

# Create Resource Group 
az group create --name $RESOURCE_GROUP --location westeurope

# Create VM
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image RHEL \
  --admin-username azureuser \
  --generate-ssh-keys

# Run Command
az vm run-command invoke \
   -g $RESOURCE_GROUP \
   -n $VM_NAME \
   --command-id RunShellScript \
   --scripts "sudo apt-get update && uname -a"

# List IP Address
az vm list-ip-addresses -o table

# Open Port
az vm open-port --port 80 --resource-group $RESOURCE_GROUP --name $VM_NAME

# Clean Up
az group delete --name $RESOURCE_GROUP
```