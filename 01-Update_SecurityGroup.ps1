################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
$nsg_name            = "redis-NSG"
$ResourceGroupName   = "ISCREAM"
$Location            = "koreacentral"
$SourceAddressPrefix = "112.223.14.90/32"
################################################################################
#                           기존 보안 그룹 업데이트                                  #
################################################################################

# nsg 정보를 가져온다.
$nsg = Get-AzNetworkSecurityGroup -Name $nsg_name -ResourceGroupName $ResourceGroupName

# 보안그룹에 추가 할 Inbound rule 작성
$nsg | Add-AzNetworkSecurityRuleConfig -Name 'HTTPS' -Description "Allow HTTPS" `
  -Access "Allow" -Protocol "Tcp" -Direction Inbound -Priority 103 `
  -SourceAddressPrefix $SourceAddressPrefix `
  -SourcePortRange "*" `
  -DestinationAddressPrefix VirtualNetwork `
  -DestinationPortRange "443"

# nsg를 업데이트한다.
$nsg | Set-AzNetworkSecurityGroup
