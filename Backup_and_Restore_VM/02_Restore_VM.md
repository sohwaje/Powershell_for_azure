# Azure CLI를 사용하여 Azure에서 가상 머신 백업

# 현재 Azure 구독 확인
```
az account list --output table
```

# 자신의 구독으로 변경
```
az account set --subscription <SubscriptionID>
```

# 사용 가능한 복구 지점 나열
```
az backup recoverypoint list --resource-group iscreamkids --vault-name kids-backup --backup-management-type AzureIaasVM --container-name front02 --item-name front02 --query [0].name --output tsv
```

# 관리 디스크 복원
- ***myRecoveryPointName***을 이전 az backup recoverypoint list 명령의 출력에서 얻은 복구 지점 이름으로 바꿉니다.
```
az backup restore restore-disks --resource-group iscreamkids --vault-name kids-backup --container-name front02 --item-name front02 --storage-account wid --rp-name 77489021901391 --target-resource-group iscreamkids
```

# 복원된 디스크에서 VM 만들기

# 작업 세부 정보 가져오기

## 작업 세부 정보에서 템플릿 Blob URI를 추출합니다.
```
az backup job show -v kids-backup -g iscreamkids -n ***<스토리지 계정의 config-myVM-1fc2d55d-f0dc-4ca6-ad48-aca0fe5d0414.json의 숫자 부분>*** --query properties.extendedInfo.propertyBag

"https://mystorageaccount.blob.core.windows.net/myVM-daa1931199fd4a22ae601f46d8812276/azuredeploy1fc2d55d-f0dc-4ca6-ad48-aca0519c0232.json"
```
- 템플릿 Blob URI는 이 형식이며 템플릿 이름을 추출합니다. 
- 템플릿은 azuredeploy1fc2d55d-f0dc-4ca6-ad48-aca0519c0232.json
- 컨테이너 이름은 myVM-daa1931199fd4a22ae601f46d8812276

# 배포 템플릿 가져오기
- 이 컨테이너의 SAS 토큰과 템플릿을 가져옵니다.
- 템플릿 Blob URI는 이 형식이며 템플릿 이름을 추출합니다.
```
https://<storageAccountName.blob.core.windows.net>/<containerName>/<templateName>
```

```
expiretime=$(date -u -d '30 minutes' +%Y-%m-%dT%H:%MZ)
connection=$(az storage account show-connection-string \
    --resource-group iscreamkids \
    --name wid \
    --query connectionString)
token=$(az storage blob generate-sas \
    --container-name front02-21d14bd40fe64c98841af58baf318ca1 \
    --name azuredeploy08d6109f-710e-43a6-bfab-66653925d0d8.json \
    --expiry $expiretime \
    --permissions r \
    --output tsv \
    --connection-string $connection)
url=$(az storage blob url \
   --container-name front02-21d14bd40fe64c98841af58baf318ca1 \
    --name azuredeploy08d6109f-710e-43a6-bfab-66653925d0d8.json \
    --output tsv \
    --connection-string $connection)
    ```
