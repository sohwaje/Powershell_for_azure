$ResourceGroupName     = "ISCREAM"
$vmName                = "TEST-VM"
$nicName               = "TEST-VM-NIC"
$nicID                 = Get-AzNetworkInterface -name $nicName | select id

# [1] VM을 중지
Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName -Force -Confirm:$false

# [2] 리소스 그룹과 VM이름을 통해서 가상 머신의 정보를 불러온다.
$VirtualMachine = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName
# [3] NIC를 제거하고 VM을 업데이트
Remove-AzVMNetworkInterface `
  -VM $VirtualMachine `
  -NetworkInterfaceIDs $nicId | `
  Update-AzVm -ResourceGroupName $ResourceGroupName

Start-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName
