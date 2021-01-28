$vmName = "vmss-template"
$rgName = "ISCREAM"
$location = "koreacentral"
$imageName = "vmssimg-api"

# 생성된 가상 머신(Linux) 아래 명령어를 통해 Deprovision을 진행한다.
# sudo waagent -deprovision+user


# 1.VM의 할당이 취소되었는지 확인합니다.
Stop-AzVM -ResourceGroupName $rgName -Name $vmName -Force

# 2.가상 머신의 상태를 일반화됨 으로 설정합니다. 일반화된 가상 머신을 사용할 수 없다.
Set-AzVm -ResourceGroupName $rgName -Name $vmName -Generalized

# 3.가상 머신을 가져옵니다.
$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName

# 4.이미지 구성을 만듭니다.
$image = New-AzImageConfig -Location $location -SourceVirtualMachineId $vm.Id

# 5.이미지를 만듭니다.
New-AzImage -Image $image -ImageName $imageName -ResourceGroupName $rgName
