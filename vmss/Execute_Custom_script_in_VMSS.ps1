# Add-AzVmssExtension 명령을 사용해 가상 머신 확장 집합에 사용자 정의 스크립트 실행
################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 #####################################
$ResourceGroupName = "ISCREAM"
$vmss_name         = "vmss-ys"
$sctip_name        = "docker_install.sh"
################################################################################
#                       사용자 지정 스크립트를 정의한다.                          #
################################################################################
# Custom Script Extension to run on the Windows Platform
# $customConfig = @{
#     "fileUris" = (,"https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate-iis.ps1");
#     "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File automate-iis.ps1"
# }
# Custom Script Extension to run on the Linux Platform
$customConfig = @{
    "fileUris" = (,"https://raw.githubusercontent.com/sohwaje/shell_scripts/master/docker_install.sh");
    "commandToExecute" = "sh docker_install.sh"
}
################################################################################
#                         가상 머신 확장 집합을 구한다.                          #
################################################################################
$vmss = Get-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $vmss_name
################################################################################
#                       사용자 정의 스크립트 실행을 위한 설정                     #
################################################################################
Add-AzVmssExtension -VirtualMachineScaleSet $vmss `
  -Name $sctip_name `
  -Publisher "Microsoft.Azure.Extensions" `
  -Type "customScript" `
  -TypeHandlerVersion 2.0 `
  -Setting $customConfig
################################################################################
#                   스크립트를 실행하고 가상머신 확장집합 업데이트                 #
################################################################################
Update-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -Name $vmss_name `
  -VirtualMachineScaleSet $vmss
