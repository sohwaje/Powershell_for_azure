################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
# 변수 설정
$resourceGroup = "ISCREAM"
$vmName = "Redis4"
$newAvailSetName = "Availabilityset-redis"

# VM 정보 가져오기
$originalVM = Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName

# 가용성 집합이 없으면 새로 만들고, 있으면 그대로 쓴다
$availSet = Get-AzAvailabilitySet `
  -ResourceGroupName $resourceGroup `
  -Name $newAvailSetName `
  -ErrorAction Ignore
  if (-Not $availSet) {
$availSet = New-AzAvailabilitySet `
  -Location $originalVM.Location `
  -Name $newAvailSetName `
  -ResourceGroupName $resourceGroup `
  -PlatformFaultDomainCount 2 `
  -PlatformUpdateDomainCount 2 `
  -Sku Aligned
  }

# 원본 VM을 삭제("Y를 누른다.")
Remove-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Force -Confirm:$false

# Create the basic configuration for the replacement VM.
$newVM = New-AzVMConfig `
  -VMName $originalVM.Name `
  -VMSize $originalVM.HardwareProfile.VmSize `
  -AvailabilitySetId $availSet.Id

# For a Linux VM, change the last parameter from -Windows to -Linux
Set-AzVMOSDisk `
  -VM $newVM -CreateOption Attach `
  -ManagedDiskId $originalVM.StorageProfile.OsDisk.ManagedDisk.Id `
  -Name $originalVM.StorageProfile.OsDisk.Name `
  -Linux

# Add Data Disks
foreach ($disk in $originalVM.StorageProfile.DataDisks) {
  Add-AzVMDataDisk -VM $newVM `
  -Name $disk.Name `
  -ManagedDiskId $disk.ManagedDisk.Id `
  -Caching $disk.Caching `
  -Lun $disk.Lun `
  -DiskSizeInGB $disk.DiskSizeGB `
  -CreateOption Attach
    }

# Add NIC(s) and keep the same NIC as primary
  foreach ($nic in $originalVM.NetworkProfile.NetworkInterfaces) {
    if ($nic.Primary -eq "True")
    {
      Add-AzVMNetworkInterface `
      -VM $newVM `
      -Id $nic.Id -Primary
    }
    else
    {
      Add-AzVMNetworkInterface `
      -VM $newVM `
      -Id $nic.Id
            }
    }

# Recreate the VM
  New-AzVM `
  -ResourceGroupName $resourceGroup `
  -Location $originalVM.Location `
  -VM $newVM `
  -DisableBginfoExtension
