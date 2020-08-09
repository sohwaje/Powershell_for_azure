$ResourceGroupName   = "ISCREAM"
# $VMName              = "TEST-VM"
$Location            = "koreacentral"
$vnet                = "Hi-Class"
$SubnetName          = "SEI-Subnet"
$nsg_name            = "TEST-NSG"
$Availabilityset     = "TEST-Availabilityset"
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
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -Name $nsg_name -SecurityRules $rule1,$rule2

# [보안그룹 생성]
New-AzNetworkSecurityGroup -Name $nsg_name `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -SecurityRules $rule1,$rule2 `
  -Force -Confirm:$false
################################################################################
#                           가상머신 확장집합 만들기                                 #
################################################################################
$availabilitySet = New-AzAvailabilitySet `
  -ResourceGroupName $ResourceGroupName `
  -Name $Availabilityset `
  -Location $Location `
  -Sku aligned `
  -PlatformFaultDomainCount 2 `
  -PlatformUpdateDomainCount 2


for ($i=1; $i -le 3; $i++)
{
    New-AzNetworkInterface `
        -Name "TEST-NIC"$i `
        -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -SubnetId $vnet.Subnets[0].Id `
        -NetworkSecurityGroupId $nsg.Id
}

################################################################################
#                           VM 만들기                                            #
################################################################################
# VM의 관리자 사용자 이름과 암호를 설정
$securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword)

# VM 생성
for ($i=1; $i -le 2; $i++)
{
    New-AzVm `
        -ResourceGroupName $ResourceGroupName `
        -Name "TEST-VM"$i `
        -Location $Location `
        -VirtualNetworkName $vnet `
        -SubnetName $SubnetName `
        -SecurityGroupName $nsg_name `
        -AvailabilitySetName $Availabilityset `
        -Credential $cred
}
