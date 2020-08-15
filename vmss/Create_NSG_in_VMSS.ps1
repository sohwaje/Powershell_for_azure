$Location             = "koreacentral"
$ResourceGroupName    = "ISCREAM"
$vmss_name            = "vmss-gaudium"
$SourceAddressPrefix  = "175.208.212.79"
$vnet_name            = "Hi-Class"
$nsg_name             = "vmss-gaudium-nsg"
$subnet_name          = "SEI-Subnet"

# Get information about the scale set
$vmss = Get-AzVmss `
            -ResourceGroupName $ResourceGroupName `
            -VMScaleSetName $vmss_name

#Create a rule to allow traffic over port 80
$nsgFrontendRule = New-AzNetworkSecurityRuleConfig `
  -Name HTTP `
  -Protocol Tcp `
  -Direction Inbound `
  -Priority 200 `
  -SourceAddressPrefix $SourceAddressPrefix `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 80 `
  -Access Allow

#Create a network security group and associate it with the rule
$nsgFrontend = New-AzNetworkSecurityGroup `
  -ResourceGroupName  $ResourceGroupName `
  -Location $Location `
  -Name $nsg_name `
  -SecurityRules $nsgFrontendRule

$vnet = Get-AzVirtualNetwork -Name $vnet_name -ResourceGroupName $ResourceGroupName
$frontendSubnet = $vnet.Subnets[11]

$frontendSubnetConfig = Set-AzVirtualNetworkSubnetConfig `
  -VirtualNetwork $vnet `
  -Name $subnet_name `
  -AddressPrefix $frontendSubnet.AddressPrefix `
  -NetworkSecurityGroup $nsgFrontend

Set-AzVirtualNetwork -VirtualNetwork $vnet

# Update the scale set and apply the Custom Script Extension to the VM instances
Update-AzVmss `
    -ResourceGroupName $ResourceGroupName `
    -Name $vmss_name `
    -VirtualMachineScaleSet $vmss
