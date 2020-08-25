<#
.SYNOPSIS
가상머신 삭제

.DESCRIPTION
파워쉘을 사용하여 가상머신을 찾아 삭제한다.
#>

[CmdletBinding()]
Param (
    [Parameter(Position = 0, Mandatory = $true, HelpMessage = '리소스그룹 이름 입력')]
    [Alias('rg')]
    [String]$ResourceGroupName,

    [Parameter(Position = 1, Mandatory = $True, HelpMessage = 'VM 이름 입력')]
    [Alias('VM')]
    [String]$vmName,

    [Parameter(Position = 2, Mandatory = $True, HelpMessage = 'DISK 이름 입력')]
    [Alias('DISK')]
    [String]$osDisk_name,

    [Parameter(Position = 3, Mandatory = $True, HelpMessage = 'NIC 이름 입력')]
    [Alias('nic')]
    [String]$nic_name,

    [Parameter(Position = 4, Mandatory = $True, HelpMessage = 'PiP 이름 입력')]
    [Alias('pip')]
    [String]$pip_name,

    [Parameter(Position = 5, Mandatory = $True, HelpMessage = 'NSG 이름 입력')]
    [Alias('nsg')]
    [String]$nsg_name,

    [Parameter(Position = 6, Mandatory = $True, HelpMessage = 'Ava 이름 입력')]
    [Alias('ava')]
    [String]$AzAvailabilitySet_name

)

Remove-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName

Remove-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $osDisk_name -Force

Remove-AzPublicIpAddress -Name $pip_name -ResourceGroupName $ResourceGroupName

Remove-AzNetworkSecurityGroup -Name $nsg_name -ResourceGroupName $ResourceGroupName

Remove-AzNetworkInterface -Name $nic_name -ResourceGroup $ResourceGroupName

Remove-AzAvailabilitySet -Name $AzAvailabilitySet_name -ResourceGroup $ResourceGroupName
