################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################################################################
#                                   변수 설정                                   #
################################################################################
$ResourceGroupName        = "ISCREAM"
$nsg_name                 = "i-screammediacorp"
$SourceAddressPrefix      = "11.1.1.1"
$DestinationAddressPrefix = "10.1.8.6"
$rulename                 = "homepage-dev-user"
$port                     = 16215
$Priority                 = 103

# NSG 정보 가져오기
$nsg = Get-AzNetworkSecurityGroup -Name $nsg_name -ResourceGroupName $ResourceGroupName

# NSG에 인바운드 Rule 추가
$nsg | Add-AzNetworkSecurityRuleConfig -Name $rulename -Description "Allow hompage-dev-user" -Access Allow `
    -Protocol * -Direction Inbound -Priority $Priority -SourceAddressPrefix $SourceAddressPrefix -SourcePortRange * `
    -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange $port

# NSG를 업데이트
$nsg | Set-AzNetworkSecurityGroup
