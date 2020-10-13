################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
$ResourceGroupName            = "ISCREAM"
$vnet_name                    = "Hi-Class"
$bastion_subnetName           = "AzureBastionSubnet"
$bastionName                  = "hiclass-bastion"
$bastionPublicIP              = "bastionPublicIP"
$location                     = "koreacentral"
# 현재 만들어진 서브넷 목록 확인하기(목록을 확인한 후 존재하지 않는 서브넷 대역을 생성한다.)
Get-AzVirtualnetwork -ResourceGroupName $ResourceGroupName | Select -ExpandProperty Subnets | Select AddressPrefix
# vnet 가져오기
$virtualNetwork = Get-AzVirtualNetwork -Name $vnet_name -ResourceGroupName $ResourceGroupName
# bastion subnet 가져오기
$bastionsubnet = Get-AzVirtualNetworkSubnetConfig -Name $bastion_subnetName  -VirtualNetwork $virtualNetwork

$virtualNetwork | Set-AzVirtualNetwork

# 배스천이 사용할 공용 IP 만들기
$publicip = New-AzPublicIpAddress `
  -ResourceGroupName $ResourceGroupName `
  -name $bastionPublicIP -location $location -AllocationMethod Static -Sku Standard

# 배스천 만들기
$bastion = New-AzBastion  `
  -Name $bastionName `
  -ResourceGroupName $ResourceGroupName `
  -PublicIpAddress $publicip `
  -VirtualNetworkId $virtualNetwork.Id
