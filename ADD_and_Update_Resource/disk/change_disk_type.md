# resource group that contains the managed disk
rgName='ISCREAM'

# Name of your managed disk
diskName='jenkins_backup_disk'

# Premium capable size 
# Required only if converting from Standard to Premium
size='Standard_D4s_v3'

# Choose between Standard_LRS, StandardSSD_LRS and Premium_LRS based on your scenario
sku='Premium_LRS'

# Get the parent VM Id 
vmId=$(az disk show --name $diskName --resource-group $rgName --query managedBy --output tsv)

# Deallocate the VM before changing the size of the VM
az vm deallocate --ids $vmId 

# Change the VM size to a size that supports Premium storage 
# Skip this step if converting storage from Premium to Standard
az vm resize --ids $vmId --size $size

# Update the SKU
az disk update --sku $sku --name $diskName --resource-group $rgName 

az vm start --ids $vmId 