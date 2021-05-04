az vm deallocate --resource-group ISCREAM --name EFK

az disk list --resource-group ISCREAM --query '[*].{Name:name,Gb:diskSizeGb,Tier:accountType}' --output table

az disk update --resource-group ISCREAM --name demo-datadisk-0 --size-gb 100

az vm start --resource-group ISCREAM --name EFK
