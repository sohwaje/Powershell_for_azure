az vm deallocate --resource-group stg-business --name smartclass

az disk list --resource-group stg-business --query '[*].{Name:name,Gb:diskSizeGb,Tier:accountType}' --output table

az disk update --resource-group stg-business --name SMARTclass_DataDisk_0 --size-gb 1000

az vm start --resource-group stg-business --name smartclass
