################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################################################################
#                                   변수 설정                                   #
################################################################################
<#
.Description
기존 nic에 새로운 nsg를 연결한다.
#>
$ResourceGroupName        = "ISCREAM"
$nsg_name                 = "bastion-nsg"
$nic_name                 = "bastion-VM-NIC"

$nic = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $nic_name
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $nsg_name
$nic.NetworkSecurityGroup = $nsg
$nic | Set-AzNetworkInterface
