az vm deallocate --resource-group quiz_rg --name quiz-vm1

az disk list \
    --resource-group quiz_rg \
    --query '[*].{Name:name,Gb:diskSizeGb,Tier:accountType}' \
    --output table

az disk update \
    --resource-group quiz_rg \
    --name quiz-osdisk-1 \
    --size-gb 100

az vm start --resource-group quiz_rg --name quiz-vm1
