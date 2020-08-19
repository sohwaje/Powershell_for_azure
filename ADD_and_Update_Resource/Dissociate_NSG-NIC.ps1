#               **** 네트워크 인터페이스에서 네트워크 보안그룹을 분리 ****                 #
################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
$ResourceGroupName        = "ISCREAM"
# 분리할 NSG 이름
$nsg_name                 = "Broadcast-Hi-Class-NSG"
$nic_name                 = "BroadcastDB-Hi-Class-NIC"

# 네트워크 인터페이스 정보 가져오기
$nic = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $nic_name
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $nsg_name

# 네트워크 인터페이스에서 nic를 분리하기 위해서 "null" 값을 입력한다.
$nic.NetworkSecurityGroup = null
$nic | Set-AzNetworkInterface
