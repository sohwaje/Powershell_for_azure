################################# 변수 설정 ######################################
$ResourceGroupName        = "ISCREAM"
$Location                 = "koreacentral"
$storageaccountName       = "examplemystorage"
$vnet_name                = "Hi-Class"
$subnet_name              = "Hi-Class-Subnet"
$storage_kind             = "BlobStorage"
$SkuName                  = "Standard_LRS"
################################# 스토리지 계정 생성#################################
<#
.Description
기존 스토리지 계정에 접근할 수 있는 가상네트워크(서브넷 포함)와 IP대력(개별 IP포함) 추가하기
.Example
1.스토리지 계정 나열하기
Get-AzStorageAccount | select StorageAccountName

2.모든 서브넷 이름과 서브넷 주소 구하기
Get-AzVirtualNetwork `
  -ResourceGroupName $ResourceGroupName `
  -Name $vnet_name | Get-AzVirtualNetworkSubnetConfig | select Name
#>
# 추가할 서브넷 구하기
$subnet = Get-AzVirtualNetwork `
  -ResourceGroupName $ResourceGroupName `
  -Name $vnet_name | Get-AzVirtualNetworkSubnetConfig `
  -Name $subnet_name

# 서브넷 추가하기
Add-AzStorageAccountNetworkRule `
  -ResourceGroupName $ResourceGroupName `
  -Name $storageaccountName `
  -VirtualNetworkResourceId $subnet.Id

# 개별 IP 주소 추가하기
Add-AzStorageAccountNetworkRule `
  -ResourceGroupName $ResourceGroupName `
  -AccountName $storageaccountName `
  -IPAddressOrRange "16.17.18.19"

# IP 주소 범위 추가하기
Add-AzStorageAccountNetworkRule `
  -ResourceGroupName $ResourceGroupName `
  -AccountName $storageaccountName `
  -IPAddressOrRange "16.17.18.0/24"

<#
.Description
스토리지 계정의 규칙 상태 확인
#>
(Get-AzStorageAccountNetworkRuleSet -ResourceGroupName $ResourceGroupName -AccountName $storageaccountName).DefaultAction

<#
.Description
가상네트워크 규칙 상태 확인
#>
(Get-AzStorageAccountNetworkRuleSet -ResourceGroupName $ResourceGroupName -AccountName $storageaccountName).VirtualNetworkRules

<#
.Description
IPAddress 규칙 상태 확인
#>
(Get-AzStorageAccountNetworkRuleSet -ResourceGroupName $ResourceGroupName -AccountName $storageaccountName).IPRules
