################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################################################################
#                                   변수 설정                                   #
################################################################################
<#
.Example
Get-AzNetworkSecurityGroup -ResourceGroupName "quiz_rg" -Name "quiz_server"
#>
$ResourceGroupName        = "webrtc"
$nsg_name                 = "testwebrtc-NetworkSecurityGroup"
# $SourceAddressPrefix      = "11.1.1.1"
# $DestinationAddressPrefix = "10.1.8.6"
$SourceAddressPrefix      = "*"
$DestinationAddressPrefix = "VirtualNetwork"
$rulename                 = "webrtc-http-rule"
$port                     = 9001,9002
$Priority                 = 200
$Description              = "Allow webrtc port"

# NSG 정보 가져오기
$nsg = Get-AzNetworkSecurityGroup -Name $nsg_name -ResourceGroupName $ResourceGroupName

# NSG에 인바운드 Rule 추가
$nsg | Add-AzNetworkSecurityRuleConfig -Name $rulename -Description $Description -Access Allow `
    -Protocol Tcp -Direction Inbound -Priority $Priority -SourceAddressPrefix $SourceAddressPrefix -SourcePortRange * `
    -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange $port

# NSG를 업데이트
$nsg | Set-AzNetworkSecurityGroup
