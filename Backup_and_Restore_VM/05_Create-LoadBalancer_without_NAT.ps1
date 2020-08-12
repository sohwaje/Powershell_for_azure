$ResourceGroupName            = "ISCREAM"
$location                     = "koreacentral"
$AllocationMethod             = "Static"
$pipName                      = "TEST-LB-PIP"
$fepName                      = "FrontendTESTPool"
$bepName                      = "BackendTESTPool"
$lbName                       = "LB-TEST"
################################################################################
#                               로드밸런서 생성                                    #
################################################################################
# [1]로드밸런서 PIP 생성
$publicIP = New-AzPublicIpAddress `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -AllocationMethod $AllocationMethod  `
  -Name $pipName

# [2]로드밸런서 생성 - 프론트엔드풀 생성
$frontendIP = New-AzLoadBalancerFrontendIpConfig `
  -Name $fepName `
  -PublicIpAddress $publicIP

# [2]로드밸런서 생성 - 백엔드풀 생성
$backendPool = New-AzLoadBalancerBackendAddressPoolConfig `
  -Name $bepName

# [3]로드밸런서 생성 - 로드밸런서 생성
$lb = New-AzLoadBalancer `
  -ResourceGroupName $ResourceGroupName `
  -Name $lbName  `
  -Location $location `
  -FrontendIpConfiguration $frontendIP `
  -BackendAddressPool $backendPool
################################################################################
#                               상태 프루브 생성                                   #
################################################################################
Add-AzLoadBalancerProbeConfig `
  -Name "HTTP" `
  -LoadBalancer $lb `
  -Protocol tcp `
  -Port 80 `
  -IntervalInSeconds 15 `
  -ProbeCount 2

Add-AzLoadBalancerProbeConfig `
  -Name "HTTPS" `
  -LoadBalancer $lb `
  -Protocol tcp `
  -Port 443 `
  -IntervalInSeconds 15 `
  -ProbeCount 2

Add-AzLoadBalancerProbeConfig `
  -Name "MySQL" `
  -LoadBalancer $lb `
  -Protocol tcp `
  -Port 3306 `
  -IntervalInSeconds 15 `
  -ProbeCount 2

# 상태프루브 설정을 로드밸런서에 적용
Set-AzLoadBalancer -LoadBalancer $lb
################################################################################
#                              로드밸런서 규칙 만들기                                #
################################################################################
$httpprobe = Get-AzLoadBalancerProbeConfig -LoadBalancer $lb -Name "HTTP"
$httspprobe = Get-AzLoadBalancerProbeConfig -LoadBalancer $lb -Name "HTTPS"

# HTTP rule
Add-AzLoadBalancerRuleConfig `
  -Name "HTTPRule" `
  -LoadBalancer $lb `
  -FrontendIpConfiguration $lb.FrontendIpConfigurations[0] `
  -BackendAddressPool $lb.BackendAddressPools[0] `
  -Protocol Tcp `
  -FrontendPort 80 `
  -BackendPort 80 `
  -Probe $httpprobe

# HTTPS Rule
Add-AzLoadBalancerRuleConfig `
  -Name "HTTPSRule" `
  -LoadBalancer $lb `
  -FrontendIpConfiguration $lb.FrontendIpConfigurations[0] `
  -BackendAddressPool $lb.BackendAddressPools[0] `
  -Protocol Tcp `
  -FrontendPort 443 `
  -BackendPort 443 `
  -Probe $httspprobe
# 로드밸랜서 규칙 적용
Set-AzLoadBalancer -LoadBalancer $lb

# 로드밸런서 테스트( 가상머신을 로드밸런서에 연결한 후에 테스트한다.)
# Get-AzPublicIPAddress `
#   -ResourceGroupName $ResourceGroupName `
#   -Name $publicIP | select IpAddress
