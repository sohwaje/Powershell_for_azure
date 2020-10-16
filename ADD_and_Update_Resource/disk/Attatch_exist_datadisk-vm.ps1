################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################################################################
#                       가상 머신에 새 관리 디스크 추가하기                             #
################################################################################
# SkuName = Premium_LRS, StandardSSD_LRS, Standard_LRS
$ResourceGroupName            = "ISCREAM"
$location                     = "koreacentral"
$vmName                       = "SlaveDB10-HiClass"
$dataDiskName                 = "MasterDB-HiClass_datadisk1"


$disk = Get-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $dataDiskName
$vm = Get-AzVM -Name $vmName -ResourceGroupName $ResourceGroupName
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 1 -VM $vm -ManagedDiskId $disk.Id
Update-AzVM -VM $vm -ResourceGroupName $ResourceGroupName
