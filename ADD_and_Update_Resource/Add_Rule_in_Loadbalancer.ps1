################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################################################################
#                                   변수 설정                                    #
################################################################################
#    ** 변수 설정 이전에 로드밸런서의 백엔드어드레스풀의 이름과, 공용IP 주소를 확인한다.  **
#    ** 여기서 확인된 값을 각각 $bePool과 $feip_name 변수의 값으로 활용한다. **
# ref : https://www.sqltattoo.com/blog/2020/06/add-a-rule-to-an-existing-azure-load-balancer/
# Get-AzLoadBalancer `
  # -Name $lb_name | `
  # select BackendAddressPools

# Get-AzLoadBalancer `
  # -Name $lb_name `
  # select FrontendIpConfigurations

# 상태 프루브를 구성 변수
$ResourceGroupName = "ISCREAM"
$probe_name        = 'prob2'
# http,https or tcp or udp
$protocol          = 'tcp'
$probe_port        = '18080'
$int               = '360'
$cnt               = '5'
# 부하분산 규칙 구성 변수(규칙 이름, 로드밸런서 이름, 백엔드어드레으풀 이름, 공용IP이름, 프론트/백엔드 포트)
$rule_name      = 'myrule'
$lb_name        = "i-screammediacorp"
$bePool_name    = "backendaddrpool0"
$feip_name      = "frontendipconf0"
$FrontendPort   = "18080"
$BackendPort    = "18080"

## 상태 프루브를 만들기(tcp일 경우는 상태 체크 경로값은 null이다.)
# Get-AzLoadBalancer -Name $lb_name -ResourceGroupName $ResourceGroupName | `
# Add-AzLoadBalancerProbeConfig `
#   -Name $probe `
#   -Protocol $protocol  `
#   -Port $probe_port `
#   -IntervalInSeconds $int -ProbeCount $cnt | `
#   Set-AzLoadBalancer
################################################################################
#                              부하분산 규칙 추가하기                            #
################################################################################
# 로드밸런서 구하기
$slb = Get-AzLoadBalancer `
  -name $lb_name `
  -ResourceGroupName $ResourceGroupName

# 백엔드어드레스 풀 구하기
$bePool = $slb | Get-AzLoadBalancerBackendAddressPoolConfig `
  -Name $bePool_name

# 프루브 추가
$slb | Add-AzLoadBalancerProbeConfig `
  -Name $probe_name `
  -Protocol $protocol  `
  -Port $probe_port `
  -IntervalInSeconds $int -ProbeCount $cnt | `
  Set-AzLoadBalancer

# 프루부 구하기
$probe = Get-AzLoadBalancerProbeConfig -Name $probe_name -LoadBalancer $slb

# 부하분산규칙 추가하기
$slb | Add-AzLoadBalancerRuleConfig `
  -Name $rule_name `
  -BackendAddressPool $bePool `
  -Protocol $protocol `
  -FrontendPort $FrontendPort `
  -BackendPort $BackendPort `
  -Probe $probe `
  -FrontendIpConfiguration $slb.FrontendIpConfigurations[0] `
  -DisableOutboundSNAT

# 로드밸런서에  설정 적용
$slb | Set-AzLoadBalancer
