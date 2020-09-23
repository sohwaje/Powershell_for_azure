################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"

<#
.SYNOPSIS
Azure 스토리지 계정 생성

.DESCRIPTION
Azure 스토리지 계정 생성
네트워크룰셋 적용

.NOTES
File Name : Create_New_storage_account.ps1

.LINK
https://docs.microsoft.com/ko-kr/azure/storage/blobs/storage-blob-create-account-block-blob?tabs=azure-portal
https://docs.microsoft.com/en-us/powershell/module/az.storage/add-azstorageaccountnetworkrule?view=azps-4.6.1
https://docs.microsoft.com/ko-kr/azure/storage/common/storage-network-security?toc=/azure/storage/blobs/toc.json#powershell
https://docs.microsoft.com/ko-kr/azure/storage/common/storage-network-security?toc=/azure/storage/blobs/toc.json#powershell
.EXAMPLE
NetworkRulSet Example
  -NetworkRuleSet (@{bypass="Logging,Metrics"
  ipRules=(@{IPAddressOrRange="10.1.0.0/16";Action="allow"},
          @{IPAddressOrRange="10.0.0.0/7";Action="allow"});
  virtualNetworkRules=(@{VirtualNetworkResourceId="/subscriptions/s1/resourceGroups/g1/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/subnet1";Action="allow"},
                      @{VirtualNetworkResourceId="/subscriptions/s1/resourceGroups/g1/providers/Microsoft.Network/virtualNetworks/vnet2/subnets/subnet2";Action="allow"});
  defaultAction="Deny"})

기존 가상네트워크 Azure Storage 서비스 엔드포인트 설정(스토리지에 제한적인 접근을 설정하기 위해서 필요)
Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $vnet_name |`
 Set-AzVirtualNetworkSubnetConfig -Name $subnet_name `
 -AddressPrefix "10.0.0.0/24" `
 -ServiceEndpoint "Microsoft.Storage" |`
  Set-AzVirtualNetwork
#>
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
.Example
모든 서브넷 이름과 서브넷 주소 구하기
Get-AzVirtualNetwork `
  -ResourceGroupName $ResourceGroupName `
  -Name $vnet_name | Get-AzVirtualNetworkSubnetConfig | select Name
#>

# 신규 스토리지 생성
New-AzStorageAccount `
  -ResourceGroupName $ResourceGroupName `
  -Name $storageaccountName `
  -Location $Location `
  -Kind $storage_kind `
  -SkuName $SkuName `
  -AccessTier Hot `
  -NetworkRuleSet (@{bypass="Logging,Metrics";
  ipRules=(@{IPAddressOrRange="175.208.212.79";Action="allow"});
  virtualNetworkRules=(@{VirtualNetworkResourceId="/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/virtualNetworks/Hi-Class/subnets/Hi-Class-Subnet";Action="allow"},
                       @{VirtualNetworkResourceId="/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/virtualNetworks/Hi-Class/subnets/Hi-ClassDB-Subnet";Action="allow"},
                       @{VirtualNetworkResourceId="/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/virtualNetworks/Hi-Class/subnets/Hi-Class-Push-App-Subnet";Action="allow"},
                       @{VirtualNetworkResourceId="/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/virtualNetworks/Hi-Class/subnets/Hi-Class-Push-DB-Subnet";Action="allow"},
                       @{VirtualNetworkResourceId="/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/virtualNetworks/Hi-Class/subnets/Hi-Class-Kube";Action="allow"},
                       @{VirtualNetworkResourceId="/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/virtualNetworks/Hi-Class/subnets/Hi-Class-Kube-Pro";Action="allow"}); defaultAction="Deny"})
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
