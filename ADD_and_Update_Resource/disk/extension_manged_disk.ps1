az vm deallocate --resource-group stg-business --name smartclass

az disk list --resource-group stg-business --query '[*].{Name:name,Gb:diskSizeGb,Tier:accountType}' --output table

az disk update --resource-group stg-business --name SMARTclass_OsDisk_1_69a534dfd9f449bcb226db3dba92ef67 --size-gb 100

az vm start --resource-group stg-business --name smartclass
