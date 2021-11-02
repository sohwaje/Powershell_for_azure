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
az backup vault create --resource-group ctool-rg --name hiclass-backup-recovery --location koreacentral
```

```
az backup vault backup-properties set --name hiclass-backup-recovery --resource-group ctool-rg --backup-storage-redundancy "LocallyRedundant"
```

# Azure VM에 백업 사용
```
az backup protection enable-for-vm --resource-group ctool-rg --vault-name hiclass-backup-recovery --vm zookeeper-ctool-dev --policy-name DefaultPolicy
```

# 백업 작업 시작
```
az backup protection backup-now --backup-management-type AzureIaasVM --resource-group ctool-rg --vault-name hiclass-backup-recovery --container-name zookeeper-ctool-dev --item-name zookeeper-ctool-dev  --retain-until 22-11-2021
```

# Azure Backup 모니터링
```
az backup job list --resource-group ctool-rg --vault-name hiclass-backup-recovery --output table
```