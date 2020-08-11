# ref : https://docs.microsoft.com/ko-kr/azure/virtual-machines/windows/tutorial-load-balancer#add-and-remove-vms
#@@@@ 로드밸런서에 가상머신을 추가하려면 가상머신은 반드시 가용성 집합에 속해 있어야 한다.
############################### 변수 설정 ########################################
$ResourceGroupName            = "ISCREAM"
$lbname                       = "LB-redis"
$nicName                      = "redis-nic4"

################################################################################
#                             로드밸런서에서 가상머신 추가                       #
################################################################################
$lb = Get-AzLoadBalancer `
    -ResourceGroupName $ResourceGroupName `
    -Name $lbname
$nic.IpConfigurations[0].LoadBalancerBackendAddressPools=$lb.BackendAddressPools[0]
Set-AzNetworkInterface -NetworkInterface $nic

################################################################################
#                             로드밸런서에서 가상머신 제거                       #
################################################################################
$nic = Get-AzNetworkInterface `
    -ResourceGroupName $ResourceGroupName `
    -Name $nicName
$nic.Ipconfigurations[0].LoadBalancerBackendAddressPools=$null
Set-AzNetworkInterface -NetworkInterface $nic
