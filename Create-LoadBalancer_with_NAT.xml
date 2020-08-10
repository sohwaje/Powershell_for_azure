## 시작 -> 실행 -> ISE
## login-azaccount

https://docs.microsoft.com/ko-kr/azure/load-balancer/quickstart-create-standard-load-balancer-powershell

변수를 설정한다.
################################################################################
$resourceGroup = "C-TFT"
$location = "koreacentral"
$publicipaddressname = "educonLB_PIP"
$frontendconfig = "educonLB-FRONTEDN_IP"
$backendpoolconfig = "educon-BACKENDPOOL"
$lbname = "educon_LOADBALANCER"

리소스 그룹을 만든다.(리소스 그룹이 생성되어 있으면 이 부분은 생략)
################################################################################
New-AzResourceGroup -ResourceGroupName $resourceGroup -Location $location

공용 IP 주소를 만든다.
################################################################################
$publicIPAddress = New-AzPublicIpAddress `
  -ResourceGroupName $resourceGroup `
  -Location $location `
  -AllocationMethod Static `
  -Name $publicipaddressname

프런트 엔드 IP 구성을 만든다.
################################################################################
$FrontendIPConfig = New-AzLoadBalancerFrontendIpConfig -Name $frontendconfig -PublicIpAddress $publicIPAddress

백 엔드 주소 풀 구성을 만든다.
################################################################################
$BackendAddressPoolConfig = New-AzLoadBalancerBackendAddressPoolConfig -Name $backendpoolconfig

상태 프로브 만들기
################################################################################
$probe = New-AzLoadBalancerProbeConfig `
 -Name 'myHealthProbe' `
 -Protocol Http -Port 80 `
 -RequestPath / -IntervalInSeconds 360 -ProbeCount 5

부하 분산 규칙 만들기
################################################################################
 $rule = New-AzLoadBalancerRuleConfig `
  -Name 'myLoadBalancerRuleWeb' -Protocol Tcp `
  -Probe $probe -FrontendPort 80 -BackendPort 80 `
  -FrontendIpConfiguration $FrontendIPConfig `
  -BackendAddressPool $BackendAddressPoolConfig

NAT 규칙 만들기
################################################################################
 $natrule1 = New-AzLoadBalancerInboundNatRuleConfig `
  -Name 'SSH' `
  -FrontendIpConfiguration $FrontendIPConfig `
  -Protocol tcp -FrontendPort 16215 `
  -BackendPort 16215

$natrule2 = New-AzLoadBalancerInboundNatRuleConfig `
  -Name 'myLoadBalancerRDP2' `
  -FrontendIpConfiguration $FrontendIPConfig `
  -Protocol tcp `
  -FrontendPort 53306 `
  -BackendPort 3306


부하 분산 장치를 만든다.(기본 LB)
################################################################################
  $loadBalancer = New-AzLoadBalancer `
    -ResourceGroupName $resourceGroup `
    -Name $lbname `
    -Location $location `
    -FrontendIpConfiguration $FrontendIPConfig `
    -BackendAddressPool $BackendAddressPoolConfig `
    -Probe $probe `
    -LoadBalancingRule $rule `
    -InboundNatRule $natrule1,$natrule2
