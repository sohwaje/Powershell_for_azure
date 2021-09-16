# 사용 가능한 복구 지점 나열
```
az backup recoverypoint list --resource-group ISCREAM --vault-name hiclass-backup-recovery --backup-management-type AzureIaasVM --container-name XCMS-Service --item-name XCMS-Service --query [0].name --output tsv

45432946402755
```

# 관리 디스크 복원
스토리지가 필요함
```
az backup restore restore-disks --resource-group ISCREAM --vault-name hiclass-backup-recovery --container-name XCMS-Service --item-name XCMS-Service --storage-account diag976 --rp-name 45432946402755 --target-resource-group ISCREAM
```

# 복원된 디스크에서 VM 만들기
## 작업 세부 정보 가져오기
- n : name
```
az backup job show -v hiclass-backup-recovery -g ISCREAM -n d8f9cb1c-7cdb-4fec-816b-337cc60c8da0 --query properties.extendedInfo.propertyBag
```

## 작업 세부 정보에서 Blob URI를 추출
```
"Template Blob Uri": "https://<storageAccountName.blob.core.windows.net>/<containerName>/<templateName>"
```

## blob URL을 이용해서 SAS 토큰 가져오기(아래 예제는 클라우드 쉘의 Bash 환경에서만 작동합니다.)
위 예제의 템플릿은 azuredeploy1fc2d55d-f0dc-4ca6-ad48-aca0519c0232.json이고 컨테이너 이름은 myVM-daa1931199fd4a22ae601f46d8812276입니다.
```
expiretime=$(date -u -d '30 minutes' +%Y-%m-%dT%H:%MZ)
connection=$(az storage account show-connection-string \
    --resource-group mystorageaccountRG \
    --name mystorageaccount \
    --query connectionString)
token=$(az storage blob generate-sas \
    --container-name myVM-daa1931199fd4a22ae601f46d8812276 \
    --name azuredeploy1fc2d55d-f0dc-4ca6-ad48-aca0519c0232.json \
    --expiry $expiretime \
    --permissions r \
    --output tsv \
    --connection-string $connection)
url=$(az storage blob url \
   --container-name myVM-daa1931199fd4a22ae601f46d8812276 \
    --name azuredeploy1fc2d55d-f0dc-4ca6-ad48-aca0519c0232.json \
    --output tsv \
    --connection-string $connection)
```

# 템플릿을 배포하여 VM 만들기
```
az deployment group create \
  --resource-group ISCREAM \
  --template-uri $url?$token
```

예제
```
admin@Azure:~$ az deployment group create \
>   --resource-group ISCREAM \
>   --template-uri $url?$token
Please provide string value for 'VirtualMachineName' (? for help): XCMS-dev
Please provide string value for 'AvailabilitySetName' (? for help): Availabilityset-XCMS
```