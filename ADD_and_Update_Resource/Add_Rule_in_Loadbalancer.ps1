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

# Get-AzLoadBalancer `
  # -Name $lb_name | `
  # select BackendAddressPools

# Get-AzLoadBalancer `
  # -Name $lb_name `
  # select FrontendIpConfigurations

# 상태 프루브를 구성 변수
$ResourceGroupName = "ISCREAM"
$probe             = 'prob3'
# http,https or tcp or udp
$protocol          = 'tcp'
$probe_port        = '18080'
$int               = '360'
$cnt               = '5'
# 부하분산 규칙 구성 변수
$rule_name      = 'myrule'
$lb_name        = "i-screammediacorp"
$bePool_name    = "backendaddrpool0"
$feip_name      = "frontendipconf0"

## 상태 프루브를 만들기(tcp일 경우는 상태 체크 경로값은 null이다.)
Get-AzLoadBalancer -Name $lb_name -ResourceGroupName $ResourceGroupName | `
Add-AzLoadBalancerProbeConfig `
  -Name $probe `
  -Protocol $protocol  `
  -Port $probe_port `
  -IntervalInSeconds $int -ProbeCount $cnt | `
  Set-AzLoadBalancer

# 부하분산 규칙 추가하기
$slb = Get-AzLoadBalancer -name $lb_name -ResourceGroupName $ResourceGroupName
$slb | Add-AzLoadBalancerRuleConfig `
  -Name $rule_name `
  -Protocol $protocol `
  -FrontendPort $port `
  -BackendPort $port `
  -FrontendIpConfiguration $slb.FrontendIpConfigurations[0] `
  -DisableOutboundSNAT | Set-AzLoadBalancer
