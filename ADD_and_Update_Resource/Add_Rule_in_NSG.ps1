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
$ResourceGroupName        = "quiz_rg"
$nsg_name                 = "quiz_server"
# $SourceAddressPrefix      = "11.1.1.1"
# $DestinationAddressPrefix = "10.1.8.6"
$SourceAddressPrefix      = "10.10.10.10","110.10.10.10","10.10.10.10"
$DestinationAddressPrefix = "10.3.1.0/24"
$rulename                 = "nodejs"
$port                     = 3000
$Priority                 = 103
$Description              = "Allow nodejs"

# NSG 정보 가져오기
$nsg = Get-AzNetworkSecurityGroup -Name $nsg_name -ResourceGroupName $ResourceGroupName

# NSG에 인바운드 Rule 추가
$nsg | Add-AzNetworkSecurityRuleConfig -Name $rulename -Description $Description -Access Allow `
    -Protocol Tcp -Direction Inbound -Priority $Priority -SourceAddressPrefix $SourceAddressPrefix -SourcePortRange * `
    -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange $port

# NSG를 업데이트
$nsg | Set-AzNetworkSecurityGroup
