# vmss의 extention을 삭제한다.
$location             = "koreacentral"
$ResourceGroupName    = "ISCREAM"
$extensionName        = "HTTPInstall"
$VMSSName             = "vmss-gaudium"

$vmss = Get-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $VMSSName

$vmss = Remove-AzVmssExtension -VirtualMachineScaleSet $vmss -Name $extensionName

Update-AzVmss `
  -Name $VMSSName `
  -ResourceGroupName $ResourceGroupName `
  -VirtualMachineScaleSet $vmss
