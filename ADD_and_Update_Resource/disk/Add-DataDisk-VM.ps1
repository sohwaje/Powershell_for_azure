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
$ResourceGroupName            = "quiz_rg"
$location                     = "koreacentral"
$vmName                       = "stagequiz-vm0"
$storageType                  = "Standard_LRS"
$dataDiskName                 = $vmName + '_datadisk1'
$DiskSize                     = 100

# 추가할 디스크 구성 설정
$diskConfig = New-AzDiskConfig `
  -SkuName $storageType `
  -Location $location `
  -CreateOption Empty `
  -DiskSizeGB $DiskSize

# 새로운 데이터 디스크 생성
$dataDisk1 = New-AzDisk `
  -DiskName $dataDiskName `
  -Disk $diskConfig `
  -ResourceGroupName $ResourceGroupName

# 디스크가 추가 될 가상 머신 정보 가져오기
$vm = Get-AzVM -Name $vmName -ResourceGroupName $ResourceGroupName
$vm = Add-AzVMDataDisk -VM $vm -Name $dataDiskName `
  -CreateOption Attach `
  -ManagedDiskId $dataDisk1.Id `
  -Lun 0

# 가상 머신 업데이트
Update-AzVM -VM $vm -ResourceGroupName $ResourceGroupName
