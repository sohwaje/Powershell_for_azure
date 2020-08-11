################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
$nsg_name                 = "TEST-nsg"
$ResourceGroupName        = "ISCREAM"
$Location                 = "koreacentral"
$SourceAddressPrefix      = "112.223.14.90/32"
$DestinationAddressPrefix = "VirtualNetwork"
################################################################################
#                           기존 보안 그룹 업데이트                                  #
################################################################################

# nsg 정보를 가져온다.
$nsg = Get-AzNetworkSecurityGroup -Name $nsg_name -ResourceGroupName $ResourceGroupName

# 변경할 Inbound rule 작성
# rule을 변경할 때는 변경할 Rule Name을 지정한다.
$nsg | Set-AzNetworkSecurityRuleConfig -Name 'allowAppPort8081' -Description 'Allow Tomcat' `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 2000 `
    -SourceAddressPrefix $SourceAddressPrefix -SourcePortRange * `
    -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange 8081

# $nsg | Set-AzNetworkSecurityRuleConfig -Name 'HTTPS' -Description 'Allow HTTPS' `
#     -Access Allow -Protocol Tcp -Direction Inbound -Priority 1001 `
#     -SourceAddressPrefix $SourceAddressPrefix -SourcePortRange * `
#     -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange 443
#
# $nsg | Set-AzNetworkSecurityRuleConfig -Name 'SSH' -Description 'Allow SSH' `
#     -Access Allow -Protocol Tcp -Direction Inbound -Priority 1002 `
#     -SourceAddressPrefix $SourceAddressPrefix -SourcePortRange * `
#     -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange 16215
#
# $nsg | Set-AzNetworkSecurityRuleConfig -Name 'MySQL' -Description 'Allow MySQL' `
#     -Access Allow -Protocol Tcp -Direction Inbound -Priority 1003 `
#     -SourceAddressPrefix $SourceAddressPrefix -SourcePortRange * `
#     -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange 3306
# nsg를 업데이트한다.
$nsg | Set-AzNetworkSecurityGroup
