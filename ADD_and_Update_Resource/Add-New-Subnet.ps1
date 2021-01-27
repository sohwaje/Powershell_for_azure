################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
$ResourceGroupName            = "ISCREAM"
$vnet_name                    = "Hi-Class"
$NewsubnetName                = "hiclass-vmss-subnet"
$NewSubnetPrefix              = "10.1.14.0/24"

# 현재 만들어진 서브넷 목록 확인하기(목록을 확인한 후 존재하지 않는 서브넷 대역을 생성한다.)
Get-AzVirtualnetwork -ResourceGroupName $ResourceGroupName | Select -ExpandProperty Subnets | Select AddressPrefix


## 기존 가상 네트워크에 서브넷 추가
# vnet 가져오기
$virtualNetwork  = Get-AzVirtualNetwork -Name $vnet_name -ResourceGroupName $ResourceGroupName
# vnet에 서브넷 생성
Add-AzVirtualNetworkSubnetConfig -Name $NewsubnetName -VirtualNetwork $virtualNetwork -AddressPrefix $NewSubnetPrefix
# vnet에 서브넷 적용
$virtualNetwork | Set-AzVirtualNetwork



# 생성한 서브넷 목록 가져오기
Get-AzVirtualNetwork -Name $vnet_name -ResourceGroupName $ResourceGroupName | select -ExpandProperty Subnets | select Name
