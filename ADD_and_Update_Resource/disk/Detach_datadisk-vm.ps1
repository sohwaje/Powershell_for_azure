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
$vmName                       = "MasterDB-HiClass"
$storageType                  = "Premium_LRS"
$dataDiskName                 = "MasterDB-HiClass_datadisk1"

<#
.Description
VM에서 해당 디스크를 분리할 때 해당 디스크가 전혀 사용되고 있지 않아야 한다.
#>

$VirtualMachine = Get-AzVM `
   -ResourceGroupName $ResourceGroupName `
   -Name $vmName
Remove-AzVMDataDisk `
   -VM $VirtualMachine `
   -Name $dataDiskName
Update-AzVM `
   -ResourceGroupName $ResourceGroupName `
   -VM $VirtualMachine
