################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################################################################
#                                   변수 설정                                   #
################################################################################
$ResourceGroupName        = "C-TFT"
$nsg_name                 = "educon_bank-NSG"
$SourceAddressPrefix      = "10.10.10.10"
$DestinationAddressPrefix = "VirtualNetwork"
$rulename                 = "admin-management-port"
$port                     = 80,443,16215,3306
$Priority                 = 101

# NSG 정보 가져오기
$nsg = Get-AzNetworkSecurityGroup -Name $nsg_name -ResourceGroupName $ResourceGroupName

# NSG에 인바운드 Rule 추가
$nsg | Add-AzNetworkSecurityRuleConfig -Name $rulename -Description "Allow Admin" -Access Allow `
    -Protocol * -Direction Inbound -Priority $Priority -SourceAddressPrefix $SourceAddressPrefix -SourcePortRange * `
    -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange $port

# NSG를 업데이트
$nsg | Set-AzNetworkSecurityGroup
