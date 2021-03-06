# Add-AzVmssExtension 명령을 사용해 가상 머신 확장 집합에 사용자 정의 스크립트 실행
# VM에는 하나의 확장 버전만 적용할 수 있습니다. 두 번째 사용자 지정 스크립트를 실행 하려면 사용자 지정 스크립트 확장을 제거 하고 업데이트 된 스크립트를 사용 하 여 다시 적용 해야 합니다.
################################################################################
#                         자격 증명을 통해 Azure에 로그인
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
$ResourceGroupName = "ISCREAM"
$vmss_name         = "example-vmss"
$script_name        = "project1"
################################################################################
#                       사용자 지정 스크립트를 정의한다.
################################################################################
# Custom Script Extension to run on the Windows Platform
# $customConfig = @{
#     "fileUris" = (,"https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate-iis.ps1");
#     "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File automate-iis.ps1"
# }
# Custom Script Extension to run on the Linux Platform
# $customConfig = @{
#     "fileUris" = (,"https://raw.githubusercontent.com/sohwaje/shell_scripts/master/httpd-install.sh");
#     "commandToExecute" = "sudo sh httpd-install.sh"
# }

$customConfigv2 = @{
    "fileUris" = (,"https://raw.githubusercontent.com/sohwaje/Powershell_for_azure/master/extensions/vmss_extensions.sh");
    "commandToExecute" = "sudo sh vmss_extensions.sh"
}
################################################################################
#                         가상 머신 확장 집합을 구한다.
################################################################################
$vmss = Get-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -VMScaleSetName $vmss_name

# $vmss.VirtualMachineProfile.ExtensonProfile[1].Extensions[1].Settings = $customConfigv2
################################################################################
#                       사용자 정의 스크립트 실행을 위한 설정
################################################################################
Add-AzVmssExtension -VirtualMachineScaleSet $vmss `
  -Name $script_name `
  -Publisher Microsoft.Azure.Extensions `
  -Type "CustomScript" `
  -TypeHandlerVersion 2.1 `
  -Setting $customConfigv2
################################################################################
#                   스크립트를 실행하고 가상머신 확장집합 업데이트
################################################################################
Update-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -Name $vmss_name `
  -VirtualMachineScaleSet $vmss

Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName | Select IpAddress
