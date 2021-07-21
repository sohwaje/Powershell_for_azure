<#
.SYNOPSIS
change subnet for azure virtual machines Name

.LINK
https://www.whatsupgold.com/blog/how-to-rename-an-azure-vm-using-powershell-a-step-by-step-guide
#>

################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
$location                   = "koreacentral"
$ResourceGroupName          = "iscreamkids"
$vmname                     = "dev-lhl-vm"
$newVMName                  = "dev-lhl-DB-VM"

# vm 속성을 가져온다.
Get-AzVM -ResourceGroupName `
  $ResourceGroupName `
  -Name $vmname | Export-Clixml /Users/yusunglee/VM_Backup.xml -Depth 5

# XML 파일에서 VM 속성을 import하고 그것을 변수에 저장한다.
$oldVM = Import-Clixml /Users/yusunglee/VM_Backup.xml

# Old VM을 삭제한다.
Remove-AzVM -ResourceGroupName $oldVM.ResourceGroupName -Name $oldVM.Name

## Creating the New Virtual Machine
# 새 가상머신을 초기화 한다.
$newVM = New-AzVMConfig -VMName $newVMName -VMSize $oldVM.HardwareProfile.VmSize -Tags $oldVM.Tags
$newVM = Set-AzVMBootDiagnostic -VM $newVM -Disable

# 새로운 VM에 old VM의 디스크를 붙인다.
Set-AzVMOSDisk `
  -VM $newVM `
  -CreateOption Attach -ManagedDiskId $oldVM.StorageProfile.OsDisk.ManagedDisk.Id `
  -Name $oldVM.StorageProfile.OsDisk.Name -Linux

# 새로운 VM에 old VM의 모든 NIC를 붙인다.
$oldVM.NetworkProfile.NetworkInterfaces | % {Add-AzVMNetworkInterface -VM $newVM -Id $_.Id}

 # old vm이 가지고 있던 다른 data disk를 부착한다.
$oldVM.StorageProfile.DataDisks | % {Add-AzVMDataDisk `
  -VM $newVM -Name $_.Name `
  -ManagedDiskId $_.ManagedDisk.Id `
  -Caching $_.Caching -Lun $_.Lun `
  -DiskSizeInGB $_.DiskSizeGB `
  -CreateOption Attach}

# Create the new virtual machine
New-AzVM -ResourceGroupName $ResourceGroupName -Location $oldVM.Location -VM $newVM


###### 암호 재설정이 요구되는 경우 az cli로 작업한다.
# az login
# az vm user update \
#   --resource-group myResourceGroup \
#   --name myVM \
#   --username azureuser \
#   --password myNewPassword
