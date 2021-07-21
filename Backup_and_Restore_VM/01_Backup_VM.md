# Azure CLI를 사용하여 Azure에서 가상 머신 백업

# 현재 Azure 구독 확인
```
az account list --output table
```

# 자신의 구독으로 변경
```
az account set --subscription <SubscriptionID>
```

# Recovery Services 자격 증명 모음 만들기

```
az backup vault create --resource-group iscreamkids --name kids-backup --location koreacentral
```

```
az backup vault backup-properties set --name kids-backup --resource-group iscreamkids --backup-storage-redundancy "LocallyRedundant"
```

# Azure VM에 백업 사용
```
az backup protection enable-for-vm --resource-group iscreamkids --vault-name kids-backup --vm front02 --policy-name DefaultPolicy
```

# 백업 작업 시작
```
az backup protection backup-now --backup-management-type AzureIaasVM --resource-group iscreamkids --vault-name kids-backup --container-name front02  --item-name front02  --retain-until 22-07-2021
```

# Azure Backup 모니터링
```
az backup job list --resource-group iscreamkids --vault-name kids-backup --output table
```