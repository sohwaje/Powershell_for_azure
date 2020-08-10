################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################################################################
#                                   변수 설정                                   #
################################################################################
$rgName = "ISCREAM"
$location = "koreacentral"
$backendpoolname = "TEST-backendpool"
$frontendpoolname = "TEST-frontendpool"
$lbname = "TEST-loadbalancer"
$security_group_name = "TEST-nsg"
$AzAvailabilitySet_name  = "TEST-Availbility-set"
$vmSize = "Standard_B1ms"
$vnet_name = "Hi-Class"
$subnet_name = "SEI-Subnet"
$OS = "CentOS"
$OS_sku = "7.7"
$OS_ver = "latest"
$pip_name = "TEST-pip"
$ip_method = "Static"
$vm1_name = "TEST-VM1"
$vm2_name = "TEST-VM2"
$nic1_name = "TEST-Nic1"
$nic2_name = "TEST-Nic2"


########################## VM의 관리자 사용자 이름과 암호를 설정 ##################
$securePassword = ConvertTo-SecureString 'Azureuser123!@#' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword)
############################## 가상네트워크 가져오기 #############################
$vnet = Get-AzVirtualNetwork -Name $vnet_name -ResourceGroupName $rgName
############################### 서브넷 가져오기 #################################
$subnet = Get-AzVirtualNetworkSubnetConfig -name $subnet_name -VirtualNetwork $vnet
################################  퍼블릭 IP 생성 ############################### #
$publicIp = New-AzPublicIpAddress -ResourceGroupName $rgName -Name $pip_name `
  -Location $location -AllocationMethod $ip_method

################################################################################
#                             로드밸런서 설정                                   #
################################################################################
# 로드밸런서 퍼블릭 IP 생성
$feip = New-AzLoadBalancerFrontendIpConfig -Name $frontendpoolname -PublicIpAddress $publicIp

# 로드밸런서 백엔드풀 설정
$bepool = New-AzLoadBalancerBackendAddressPoolConfig -Name $backendpoolname

# 상태 프루브 설정 80 port
$probe_http = New-AzLoadBalancerProbeConfig -Name 'HTTP' -Protocol Http -Port 80 `
-RequestPath / -IntervalInSeconds 360 -ProbeCount 5

# 상태 프루브 설정 443 port
$probe_https = New-AzLoadBalancerProbeConfig -Name 'HTTPS' -Protocol tcp -Port 443 `
-IntervalInSeconds 360 -ProbeCount 5

# 로드밸런서 룰 for 80 포트
$rule_http = New-AzLoadBalancerRuleConfig -Name 'HTTP' -Protocol Tcp `
  -Probe $probe_http -FrontendPort 80 -BackendPort 80 `
  -FrontendIpConfiguration $feip -BackendAddressPool $bePool

# 로드밸런서 룰 443 포트
$rule_https = New-AzLoadBalancerRuleConfig -Name 'HTTPS' -Protocol Tcp `
  -Probe $probe_https -FrontendPort 443 -BackendPort 443 `
  -FrontendIpConfiguration $feip -BackendAddressPool $bePool

# NAT SSH <-> TCP 16215 port
$natrule1 = New-AzLoadBalancerInboundNatRuleConfig -Name 'SSH' `
  -FrontendIpConfiguration $feip `
  -Protocol tcp -FrontendPort 16215 -BackendPort 16215

# NAT MySQL <-> TCP 3306 port
$natrule2 = New-AzLoadBalancerInboundNatRuleConfig -Name 'MySQL' `
  -FrontendIpConfiguration $feip `
  -Protocol tcp -FrontendPort 53306 -BackendPort 3306

# 로드밸런서 생성
$lb = New-AzLoadBalancer -ResourceGroupName $rgName -Name $lbname `
  -Location $location `
  -FrontendIpConfiguration $feip -BackendAddressPool $bepool `
  -Probe $probe_http,$probe_https -LoadBalancingRule $rule_http,$rule_https `
  -InboundNatRule $natrule1,$natrule2

################################################################################
#                               보안 그룹                                       #
################################################################################
# 보안그룹 룰 생성
$rule1 = New-AzNetworkSecurityRuleConfig -Name 'HTTP' -Description 'Allow HTTP' `
  -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 `
  -SourceAddressPrefix Internet -SourcePortRange * `
  -DestinationAddressPrefix * -DestinationPortRange 80

$rule2 = New-AzNetworkSecurityRuleConfig -Name 'HTTPS' -Description 'Allow HTTPS' `
  -Access Allow -Protocol Tcp -Direction Inbound -Priority 1001 `
  -SourceAddressPrefix Internet -SourcePortRange * `
  -DestinationAddressPrefix * -DestinationPortRange 443

$rule3 = New-AzNetworkSecurityRuleConfig -Name 'SSH' -Description 'Allow SSH' `
  -Access Allow -Protocol Tcp -Direction Inbound -Priority 1002 `
  -SourceAddressPrefix Internet -SourcePortRange * `
  -DestinationAddressPrefix * -DestinationPortRange 16215

$rule4 = New-AzNetworkSecurityRuleConfig -Name 'MySQL' -Description 'Allow MySQL' `
  -Access Allow -Protocol Tcp -Direction Inbound -Priority 1003 `
  -SourceAddressPrefix Internet -SourcePortRange * `
  -DestinationAddressPrefix * -DestinationPortRange 3306

# 보안 그룹 생성
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $rgName -Location $location `
-Name $security_group_name -SecurityRules $rule1,$rule2,$rule3,$rule4

################################################################################
#                      NIC에 퍼블릭IP와 NSG 매핑                                #
################################################################################
$nicVM1 = New-AzNetworkInterface -ResourceGroupName $rgName -Location $location `
  -Name $nic1_name -LoadBalancerBackendAddressPool $bepool `
  -NetworkSecurityGroup $nsg `
  -LoadBalancerInboundNatRule $natrule1 -Subnet $subnet

$nicVM2 = New-AzNetworkInterface -ResourceGroupName $rgName -Location $location `
  -Name $nic2_name -LoadBalancerBackendAddressPool $bepool `
  -NetworkSecurityGroup $nsg `
  -LoadBalancerInboundNatRule $natrule2 -Subnet $subnet

################################################################################
#                             가용성 집합 생성                                  #
################################################################################
$as = New-AzAvailabilitySet -ResourceGroupName $rgName -Location $location `
  -Name $AzAvailabilitySet_name -Sku Aligned -PlatformFaultDomainCount 2 `
  -PlatformUpdateDomainCount 2

################################################################################
#                               가상머신 생성                                   #
################################################################################
# VM1 가상머신 설정
$vmConfig = New-AzVMConfig -VMName $vm1_name -VMSize $vmSize -AvailabilitySetId $as.Id | `
  Set-AzVMOperatingSystem -Linux -ComputerName $vm1_name -Credential $cred | `
  Set-AzVMSourceImage -PublisherName OpenLogic -Offer $OS `
  -Skus $OS_sku -Version $OS_ver | Add-AzVMNetworkInterface -Id $nicVM1.Id
# 가상 머신 생성
$vm1 = New-AzVM -ResourceGroupName $rgName -Location $location -VM $vmConfig

# VM2 가상머신 설정
$vmConfig = New-AzVMConfig -VMName $vm2_name -VMSize $vmSize -AvailabilitySetId $as.Id | `
  Set-AzVMOperatingSystem -Linux -ComputerName $vm2_name -Credential $cred | `
  Set-AzVMSourceImage -PublisherName OpenLogic -Offer $OS `
  -Skus $OS_sku -Version $OS_ver | Add-AzVMNetworkInterface -Id $nicVM2.Id
# 가상 머신 생성
$vm2 = New-AzVM -ResourceGroupName $rgName -Location $location -VM $vmConfig
