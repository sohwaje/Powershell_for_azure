az vm deallocate --resource-group ISCREAM --name TEST-VM

az disk list --resource-group ISCREAM --query '[*].{Name:name,Gb:diskSizeGb,Tier:accountType}' --output table

az disk update --resource-group ISCREAM --name TEST-OS-DIsk --size-gb 100

az vm start --resource-group ISCREAM --name TEST-VM
