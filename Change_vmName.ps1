################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
$ResourceGroupName = 'ISCREAM'
# 변경 대상 가상 머신 이름
$oldVMName = 'Redis4'
# 새 가상 머신의 이름을 설정한다.
$newVMName = 'Redis5'

# 가성머신 속성을 xml 파일로 저장한다.
Get-AzVM -ResourceGroupName $ResourceGroupName -Name $oldVMName `
 | Export-Clixml \Users\yusunglee\Downloads\Azure\VM_Backup.xml `
 -Depth 5

# 변수 값에 xml 파일을 불러온다.
$oldVM = Import-Clixml \Users\yusunglee\Downloads\Azure\VM_Backup.xml

# VM을 삭제한다.
Remove-AzVM -ResourceGroupName $oldVM.ResourceGroupName -Name $oldVM.Name `
-Force -Confirm:$false

# VM 구성을 초기화 한다.
$newVM = New-AzVMConfig -VMName $newVMName `
-VMSize $oldVM.HardwareProfile.VmSize `
-Tags $oldVM.Tags

# Old VM의 OS 디스크를 New VM에 추가한다.
Set-AzVMOSDisk -VM $newVM -CreateOption Attach `
-ManagedDiskId $oldVM.StorageProfile.OsDisk.ManagedDisk.Id `
-Name $oldVM.StorageProfile.OsDisk.Name `
-Linux

# Old VM의 모든 NIC를 New VM에 추가한다.
$oldVM.NetworkProfile.NetworkInterfaces | % {Add-AzVMNetworkInterface -VM $newVM -Id $_.Id}

# Old VM의 모든 디스크를 New VM에 추가한다.
$oldVM.StorageProfile.DataDisks | % {Add-AzVMDataDisk `
  -VM $newVM -Name $_.Name `
  -ManagedDiskId $_.ManagedDisk.Id `
  -Caching $_.Caching -Lun $_.Lun `
  -DiskSizeInGB $_.DiskSizeGB `
  -CreateOption Attach}

# New VM을 생성한다.
New-AzVM -ResourceGroupName $ResourceGroupName -Location $oldVM.Location -VM $newVM
