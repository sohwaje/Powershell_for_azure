################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################################################################
#                                   변수 설정                                   #
################################################################################
$ResourceGroupName = "ISCREAM"
$vmName            = "TEST-VM1"

# [1] VM을 중지
Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName -Force -Confirm:$false

$VirtualMachine = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName
# [2] Get-AzNetworkInterface -Name *NIC_NAME* | select ID  : 해당 *NIC_NAME*의 구독 ID를 찾는다.
####################################################################################################################################
#$ Get-AzNetworkInterface -Name *NIC_NAME* | select ID                                                                             #
#Id                                                                                                                                #
#--                                                                                                                                #
#/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/networkInterfaces/TEST-Nic1#
#/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/networkInterfaces/TEST-Nic2#
####################################################################################################################################

# [3] 찾은 구독 ID를 "-Id" 파라미터와 함께 명시한다.
Add-AzVMNetworkInterface -VM $VirtualMachine `
  -Id "/subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Network/networkInterfaces/TEST11-nic" -Primary
Update-AzVM `
  -ResourceGroupName $ResourceGroupName `
  -VM $VirtualMachine

# [4] VM을 다시 시작
Start-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName

# VM 상태 확인
# Get-Azvm -Name TEST-VM1 -Status
