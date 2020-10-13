################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 #####################################
$ResourceGroupName        = "ISCREAM"
$Location                 = "koreacentral"
$vet                      = "Hi-Class"
$subnet_name              = "Hi-Class-Subnet"
$newpublicIpName          = "bastion-PIP"
$vmName                   = "bastion-VM"
$IpConfigName             = "bastion-IPConfig"
#기존 NIC 이름
$exitedvmNIC              = "bastion-VM-NIC"

# Get-AzPublicIpAddress -Name myPublicIp*
################################################################################
#                           신규 공용 IP 생성                                   #
################################################################################
$newpublicIp = New-AzPublicIpAddress `
  -Name $newpublicIpName `
  -ResourceGroupName $ResourceGroupName `
  -AllocationMethod Static `
  -Location $Location
# 공용 IP 확인
# Get-AzPublicIpAddress -ResourceGroupName "myResourceGroup" | Select "IpAddress"
################################################################################
#                   신규 공용 IP를 기존 가상 머신의 NIC에 적용                    #
################################################################################
$vnet = Get-AzVirtualNetwork -Name $vet -ResourceGroupName $ResourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnet_name -VirtualNetwork $vnet
$nic = Get-AzNetworkInterface -Name $exitedvmNIC -ResourceGroupName $ResourceGroupName
$pip = Get-AzPublicIpAddress -Name $newpublicIpName -ResourceGroupName $ResourceGroupName
$nic | Set-AzNetworkInterfaceIpConfig -Name $IpConfigName -PublicIPAddress $newpublicIp -Subnet $subnet
$nic | Set-AzNetworkInterface
