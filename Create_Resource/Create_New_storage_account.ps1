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

.EXAMPLE
NetworkRulSet Example
  -NetworkRuleSet (@{bypass="Logging,Metrics"
  ipRules=(@{IPAddressOrRange="10.1.0.0/16";Action="allow"},
          @{IPAddressOrRange="10.0.0.0/7";Action="allow"});
  virtualNetworkRules=(@{VirtualNetworkResourceId="/subscriptions/s1/resourceGroups/g1/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/subnet1";Action="allow"},
                      @{VirtualNetworkResourceId="/subscriptions/s1/resourceGroups/g1/providers/Microsoft.Network/virtualNetworks/vnet2/subnets/subnet2";Action="allow"});
  defaultAction="Deny"})

#>
################################# 변수 설정 ######################################
$ResourceGroupName        = "ISCREAM"
$Location                 = "koreacentral"
$storageaccountName       = "cacheforhiclass"
$vnet_name                = "Hi-Class"

################################# 스토리지 계정 생성#################################
# New-AzStorageAccount `
#   -ResourceGroupName $ResourceGroupName `
#   -Name $storageaccountName `
#   -Location $Location `
#   -Kind "BlobStorage" `
#   -SkuName "Standard_LRS" `
#   -AccessTier Hot
  # -NetworkRuleSet (@{bypass="Logging,Metrics";
  # ipRules=(@{IPAddressOrRange="10.1.0.0/24";Action="allow"},
  #          @{IPAddressOrRange="10.1.3.0/24";Action="allow"},
  #          @{IPAddressOrRange="10.1.4.0/24";Action="allow"},
  #          @{IPAddressOrRange="10.1.5.0/24";Action="allow"},
  #          @{IPAddressOrRange="10.1.12.0/24";Action="allow"},
  #          @{IPAddressOrRange="10.1.13.0/24";Action="allow"});
  # virtualNetworkRules=(@{VirtualNetworkResourceId="/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/virtualNetworks/Hi-Class/subnets/Hi-Class-Subnet";Action="allow"},
  #                      @{VirtualNetworkResourceId="/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/virtualNetworks/Hi-Class/subnets/Hi-ClassDB-Subnet";Action="allow"},
  #                      @{VirtualNetworkResourceId="/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/virtualNetworks/Hi-Class/subnets/Hi-Class-Push-App-Subnet";Action="allow"},
  #                      @{VirtualNetworkResourceId="/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/virtualNetworks/Hi-Class/subnets/Hi-Class-Push-DB-Subnet";Action="allow"},
  #                      @{VirtualNetworkResourceId="/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/virtualNetworks/Hi-Class/subnets/Hi-Class-Kube";Action="allow"},
  #                      @{VirtualNetworkResourceId="/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/virtualNetworks/Hi-Class/subnets/Hi-Class-Kube-Pro";Action="allow"});
  # defaultAction="Deny"})
$subnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $vnet_name | Get-AzVirtualNetworkSubnetConfig
Add-AzStorageAccountNetworkRule -ResourceGroupName $ResourceGroupName -Name $storageaccountName -VirtualNetworkResourceId $subnet[13].Id
