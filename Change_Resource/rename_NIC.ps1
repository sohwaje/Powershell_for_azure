<#
.SYNOPSIS
Rename Azure VM NIC.

.DESCRIPTION
Rename Azure Network Adapter interface for Linux and Windows VM.

.NOTES
File Name : Rename-AzVMNIC.ps1
Author    : Microsoft MVP - Charbel Nemnom
Version   : 1.0
Date      : 22-September-2019
Update    : 25-September-2019
Requires  : PowerShell 5.1 or PowerShell 7 (Core)
Module    : Az Module
OS        : Windows or Linux VMs

.LINK
To provide feedback or for further assistance please visit: https://charbelnemnom.com

.EXAMPLE
.\Rename-AzVMNIC.ps1 -resourceGroup [ResourceGroupName] -VMName [VMName] -NewNicName [NewNicName] -Verbose
This example will rename the NIC interface for the specified VM, you need to specify the Resource Group name, VM name and the new NIC name.
The script will preserve the old network settings and apply them to the new network interface.
#>

[CmdletBinding()]
Param (
    [Parameter(Position = 0, Mandatory = $true, HelpMessage = 'Enter the Resource Group of the VM')]
    [Alias('rg')]
    [String]$resourceGroup,

    [Parameter(Position = 1, Mandatory = $True, HelpMessage = 'Enter Azure VM name')]
    [Alias('VM')]
    [String]$VMName,

    [Parameter(Position = 2, Mandatory = $true, HelpMessage = 'Enter the desired NIC interface name')]
    [Alias('NewNIC')]
    [String]$NewNicName
)

#! Check Azure Connection
Try {
    Write-Verbose "Connecting to Azure Cloud..."
    Connect-AzAccount -ErrorAction Stop | Out-Null
}
Catch {
    Write-Warning "Cannot connect to Azure Cloud. Please check your credentials. Exiting!"
    Break
}

#! Get the details of the VM
Write-Verbose "Get the VM information details: $VMName"
$VM = Get-AzVM -Name $VMName -ResourceGroupName $resourceGroup

#! Get the virtual NIC interface name and details
Write-Verbose "Get the old virtual NIC interface name and details..."
$oldNicName = $VM.NetworkProfile.NetworkInterfaces.Id.Split('/')[-1]
$vNic = Get-AzNetworkInterface -Name $oldNicName -ResourceGroupName $resourceGroup

#! Get the public ip address of the virtual machine if exists.
If ($VNic.IpConfigurations.publicIPAddress.Id -ne $null) {
    $PIpName = $VNic.IpConfigurations.publicIPAddress.Id.Split('/')[-1]
    $vNic.IpConfigurations.publicipaddress.id = $null
    Write-Verbose "Dissociate the public IP address from the VM: $PIpName"
    Set-AzNetworkInterface -NetworkInterface $vnic | Out-Null
}

#! Stop the VMName
Write-Verbose "Stop and deallocate the VM: $VMName, please wait..."
Stop-AzVM -Name $VMName -ResourceGroupName $resourceGroup -Force -Confirm:$false | Out-Null

#! Create the new virtual NIC interface
Write-Verbose "Creating the new virtual Network interface..."
$NIC = New-AzNetworkInterface -Name $NewNicName -ResourceGroupName $resourceGroup `
    -Location $VM.Location -SubnetId $vnic.IpConfigurations.Subnet.Id `
    -IpConfigurationName $vnic.IpConfigurations.Name

#! Remove the old NIC interface from the VM
Write-Warning "Removing the old NIC interface: $($oldNicName) from the VM: $VMName"
Remove-AzVMNetworkInterface -vm $VM -NetworkInterfaceIDs $vNic.Id | Out-Null

#! Add the new NIC interface
Write-Verbose "Adding the new network adapter interface to the VM..."
Add-AzVMNetworkInterface -VM $VM -NetworkInterface $NIC | Update-AzVM -ResourceGroupName $resourceGroup | Out-Null

#! Delete the old NIC interface resource
Write-Warning "Deleting the old NIC interface: $($oldNicName)"
Remove-AzNetworkInterface -Name $oldNicName -ResourceGroupName $vNic.ResourceGroupName -Force -Confirm:$false

#! Update the new virtual NIC settings
$NIC = Get-AzNetworkInterface -Name $NewNicName -ResourceGroupName $resourceGroup
If ($vNic.Tag -ne $null) {
    $NIC = $vNIC.Tags
}
$NIC.DnsSettings = $vNIC.DnsSettings
$NIC.EnableIPForwarding = $vNIC.EnableIPForwarding
$NIC.EnableAcceleratedNetworking = $vNIC.EnableAcceleratedNetworking
$NIC.NetworkSecurityGroup = $vNIC.NetworkSecurityGroup
#! Set the new virtual NIC settings
Write-Verbose "Set the new NIC interface settings..."
If ($NIC.IpConfigurations.PrivateIpAddress -ne $vNIC.IpConfigurations.PrivateIpAddress) {
    Set-AzNetworkInterfaceIpConfig -NetworkInterface $NIC -Name $NIC.IpConfigurations.Name `
        -PrivateIpAddressVersion $vNIC.IpConfigurations.PrivateIpAddressVersion `
        -PrivateIpAddress $vNIC.IpConfigurations.PrivateIpAddress -SubnetId $vnic.IpConfigurations.Subnet.id | Out-Null
}
Set-AzNetworkInterface -NetworkInterface $NIC | Out-Null

#! Create a public IP for the VM.
If ($PIpName) {
    $PublicIp = Get-AzPublicIpAddress -Name $PIpName -ResourceGroupName $resourceGroup
    $NIC | Set-AzNetworkInterfaceIpConfig -Name $NIC.IpConfigurations.Name -PublicIPAddress $PublicIp `
        -Subnet $vnic.IpConfigurations.Subnet | Out-Null
    Write-Verbose "Associate the public IP address to the VM: $PIpName"
    Set-AzNetworkInterface -NetworkInterface $NIC | Out-Null
}

#! Start the VMName
Write-Verbose "Start the VM: $VMName, please wait..."
Start-AzVM -Name $VMName -ResourceGroupName $resourceGroup -Confirm:$false | Out-Null
