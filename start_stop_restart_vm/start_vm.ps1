$vmName               = "TEST-VM"
$ResourceGroupName    = "ISCREAM"

Get-AzVM -Name $vmName `
  -ResourceGroupName $ResourceGroupName `
  | Stop-AzVM
