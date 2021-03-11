################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################################################################
#                                   변수 설정                                   #
################################################################################
$ResourceGroupName = "stg-business"
$vmName            = "SMARTclass"
$VmSize            = "Standard_E16-4as_v4"
# 0. 사용 가능한 리소스 찾기
Get-AzVMSize -Location "koreacentral"

# 1. 리소스 그룹명, 가상머신 이름
$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -VMName $vmName

# 2. 변경할 사이즈 이름
$vm.HardwareProfile.VmSize = $VmSize

# 3. 사이즈 변경
Update-AzVM -VM $vm -ResourceGroupName $ResourceGroupName
