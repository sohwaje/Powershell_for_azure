################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"

################################# 변수 설정 ######################################
$nsg_name            = "TEST-NSG"
$ResourceGroupName   = "ISCREAM"
$Location            = "koreacentral"
$SourceAddressPrefix = "112.223.14.90/32"
################################################################################
#                           신규 보안 그룹 생성                                     #
################################################################################
#[보안그룹 rule 생성]
$rule1 = New-AzNetworkSecurityRuleConfig -Name 'SSH' -Description "Allow RDP" `
  -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
  -SourceAddressPrefix $SourceAddressPrefix `
  -SourcePortRange * `
  -DestinationAddressPrefix VirtualNetwork `
  -DestinationPortRange 22

$rule2 = New-AzNetworkSecurityRuleConfig -Name 'WEB' -Description "Allow HTTP" `
  -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 `
  -SourceAddressPrefix $SourceAddressPrefix `
  -SourcePortRange * `
  -DestinationAddressPrefix VirtualNetwork `
  -DestinationPortRange 80

# [새로 생성할 nsg에 룰을 적용한다.]
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $Location `
  -Name "NSG-FrontEnd" -SecurityRules $rule1,$rule2

# [보안그룹 생성]
New-AzNetworkSecurityGroup -Name $nsg_name `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -SecurityRules $rule1,$rule2 `
  -Force -Confirm:$false
