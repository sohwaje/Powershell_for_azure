# vmss의 사용자정의 스크립트를 위한 extention을 삭제한다.
################################################################################
#                         자격 증명을 통해 Azure에 로그인
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
$location             = "koreacentral"
$ResourceGroupName    = "ISCREAM"
$extensionName        = "HTTPInstall"
$VMSSName             = "vmss-gaudium"

# 가상머신확장집합 가져오기
$vmss = Get-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -VMScaleSetName $VMSSName

# 삭제할 extension 이름 가져오기
$vmss = Remove-AzVmssExtension `
  -VirtualMachineScaleSet $vmss `
  -Name $extensionName

# 변경된 내용을 바탕으로 가상머신 확장집합을 업데이트 한다.
Update-AzVmss `
  -Name $VMSSName `
  -ResourceGroupName $ResourceGroupName `
  -VirtualMachineScaleSet $vmss
