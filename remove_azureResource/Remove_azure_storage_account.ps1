<#
.Description
1.스토리지 계정 나열하기
Get-AzStorageAccount | select StorageAccountName
#>
################################# 변수 설정 ######################################
$ResourceGroupName        = "ISCREAM"
$Location                 = "koreacentral"
$storageaccountName       = "examplemystorage"

# 스토리지 계정 삭제
Remove-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $storageaccountName
