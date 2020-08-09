################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"

# 변수 설정
$ResourceGroupName = "ISCREAM"
$nic_name = "redis-nic4"
$nsg_name = "redis-NSG"

# 기존 네트워크 인터페이스를 가져 와서 $nic 변수에 저장
$nic = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $nic_name

# 기존 네트워크 보안 그룹을 가져 와서 $nsg 변수에 저장
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $nsg_name

# $nsg를 $nic에 할당
$nic.NetworkSecurityGroup = $nsg

# 변경 사항을 네트워크 인터페이스에 적용
$nic | Set-AzNetworkInterface

###### tip
# 네트워크 인터페이스에서 네트워크 보안 그룹을 분리($nsg -> $null로 변경)
# $nic.NetworkSecurityGroup = $null
