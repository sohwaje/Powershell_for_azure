$Location             = "koreacentral"
$ResourceGroupName    = "ISCREAM"
$vmss_name            = "vmss-example"
$SourceAddressPrefix  = "175.208.212.79"
$vnet_name            = "Hi-Class"
$nsg_name             = "vmss-example-nsg"
$subnet_name          = "hiclass-vmss-subnet"

# Get information about the scale set
$vmss = Get-AzVmss `
            -ResourceGroupName $ResourceGroupName `
            -VMScaleSetName $vmss_name

#Create a rule to allow traffic over port 80,443
$nsgRuleParams = @{
  Name = 'HTTP'
  Protocol = 'Tcp'
  Direction = 'Inbound'
  Priority = 200
  SourceAddressPrefix = $SourceAddressPrefix
  SourcePortRange = '*'
  DestinationAddressPrefix = '*'
  DestinationPortRange = 80
  Access = 'Allow'
}
$nsgRule = New-AzNetworkSecurityRuleConfig @nsgRuleParams


$nsgParams = @{
  ResourceGroupName = $ResourceGroupName
  Location = $Location
  Name = $nsg_name
  SecurityRules = $nsgRule
}
$nsg = New-AzNetworkSecurityGroup @nsgParams

$vnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $vnet_name

$subnet = $vnet.Subnets[14]
$subnetConfigParams = @{
  VirtualNetwork = $vnet
  Name = $subnet_name
  AddressPrefix = $subnet.AddressPrefix
  NetworkSecurityGroup = $nsg
}
$subnetConfig = Set-AzVirtualNetworkSubnetConfig @subnetConfigParams


Set-AzVirtualNetwork -VirtualNetwork $vnet

# Update the scale set and apply the Custom Script Extension to the VM instances
$vmss = Get-AzVmss `
            -ResourceGroupName $ResourceGroupName `
            -VMScaleSetName $vmss_name

Update-AzVmss `
    -ResourceGroupName $ResourceGroupName `
    -Name $vmss_name `
    -VirtualMachineScaleSet $vmss
