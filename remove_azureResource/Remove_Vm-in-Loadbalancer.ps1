############################### 변수 설정 ########################################
$ResourceGroupName            = "ISCREAM"
$lbname                       = "LB-redis"
$nicName                      = "redis-nic4"
################################################################################
#                             로드밸런서에서 가상머신 제거                       #
################################################################################
$nic = Get-AzNetworkInterface `
    -ResourceGroupName $ResourceGroupName `
    -Name $nicName
$nic.Ipconfigurations[0].LoadBalancerBackendAddressPools=$null
Set-AzNetworkInterface -NetworkInterface $nic
