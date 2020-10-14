<#
.SYNOPSIS
change subnet for azure virtual machines ( asm-arm) NIC card

.DESCRIPTION
change subnet for azure virtual machines ( asm-arm) NIC card

.NOTES
File Name : change_subnet_vm.ps1


.LINK
https://supporthost.in/how-to-change-subnet-for-azure-virtual-machines-asm-arm-nic-card/
#>

################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
$location                   = "koreacentral"
$ResourceGroupName          = "ISCREAM"
$vnet_name                  = "Hi-Class"
$nic_name                   = "bastion-VM-NIC"
# 변경할 서브넷 이름
$newsubnet_name             = "SEI-Subnet"

$vnet   = Get-AzVirtualNetwork -Name $vnet_name -ResourceGroupName $ResourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $newsubnet_name -VirtualNetwork $vnet
$nic    = Get-AzNetworkInterface -Name $nic_name -ResourceGroupName $ResourceGroupName

# PrivateIpAddress : 서브넷에서 할당 받을 IP 주소
$nic | Set-AzNetworkInterfaceIpConfig -Name bastion-IPConfig -PrivateIpAddress 10.1.11.100 -Subnet $subnet -Primary
$nic | Set-AzNetworkInterface
