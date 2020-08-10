## 시작 -> 실행 -> ISE
## login-azaccount
## 부하 분산 장치에 가상 머신 추가하기

# 변수를 설정한다.
###############################################
$resourceGroup = "C-TFT"
$lbname = "educon_LOADBALANCER"
$nicName = "vm-educonbank-NIC"

# nic 정보 가져오기
################################################
$nic = Get-AzNetworkInterface -ResourceGroupName $resourceGroup -Name $nicName

# 부하분산장치 가져오기
#################################################
$loadBalancer = Get-AzLoadBalancer -ResourceGroupName $resourceGroup -Name $lbname

# nic의 IP를 로드밸런서 백엔드풀에 추가하기
$nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $loadBalancer.BackendAddressPools[0]

# 적용하기
Set-AzNetworkInterface -NetworkInterface $nic
