################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################################################################
#                                   변수 설정                                   #
################################################################################
$ResourceGroupName = "ISCREAM"
$vnet_name         = "Hi-Class"
$Location          = "koreacentral"
$IPconfig_name     = "TEST11-IPConfig1"
$PrivateIpAddress  = "10.1.11.13"
$nic_name          = "TEST11-nic"

################################################################################
#                                   새 NIC 생성                                 #
################################################################################
$Subnet = Get-AzVirtualNetwork `
  -ResourceGroupName $ResourceGroupName `
  -Name $vnet_name

$IPconfig = New-AzNetworkInterfaceIpConfig `
  -Name $IPconfig_name `
  -PrivateIpAddressVersion IPv4 `
  -PrivateIpAddress $PrivateIpAddress `
  -SubnetId $Subnet.Subnets[11].Id    # [11]은 vnet의 서브넷 리스트 순서

New-AzNetworkInterface `
  -Name $nic_name `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -IpConfiguration $IPconfig
