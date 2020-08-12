################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
$ResourceGroupName        = "ISCREAM"
$nsg_name                 = "i-screammediacorp"
$SourceAddressPrefix      = "*"
$DestinationAddressPrefix = "VirtualNetwork"
$rulename                 = "HTTP"
$port                     = 80
$Priority                 = 101
################################################################################
#                           기존 보안 그룹 업데이트                              #
################################################################################

# nsg 정보를 가져온다.
$nsg = Get-AzNetworkSecurityGroup -Name $nsg_name -ResourceGroupName $ResourceGroupName

# 변경할 Inbound rule 작성
# rule을 변경할 때는 변경할 Rule Name을 지정한다.
$nsg | Set-AzNetworkSecurityRuleConfig -Name 'HTTP' -Description 'Allow HTTP' `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 `
    -SourceAddressPrefix $SourceAddressPrefix -SourcePortRange * `
    -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange 80

# nsg를 업데이트한다.
$nsg | Set-AzNetworkSecurityGroup
