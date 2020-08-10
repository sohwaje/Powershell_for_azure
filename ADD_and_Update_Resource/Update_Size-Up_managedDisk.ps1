################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"

# 새 디스크는 기존 크기보다 커야한다.
# OS 디스크에 허용되는 최대 크기는 2,048GB이다.
# VM을 다시 시작해야 한다.
$rgName = 'ISCREAM'
$vmName = 'Redis4'

# VM에 대한 참조를 얻는다.
$vm = Get-AzVM -ResourceGroupName $rgName -Name $vmName

# VM을 중지한 후 디스크의 크기를 조정합니다.
Stop-AzVM -ResourceGroupName $rgName -Name $vmName -Force -Confirm:$false

# OS 디스크의 크기 조정
$disk= Get-AzDisk -ResourceGroupName $rgName -DiskName $vm.StorageProfile.OsDisk.Name
$disk.DiskSizeGB = 50
Update-AzDisk -ResourceGroupName $rgName -Disk $disk -DiskName $disk.Name

# VM을 다시 시작
Start-AzVM -ResourceGroupName $rgName -Name $vmName
