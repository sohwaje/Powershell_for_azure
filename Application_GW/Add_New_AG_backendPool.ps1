################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################################################################
#                                   변수 설정                                   #
################################################################################
$resourceGroups           = "ISCREAM"
$vnet_name                = "Hi-Class"
$AG_Subnet_name           = "AG-ONLY-SUBNET"
$AG_name                  = "AG-HICLASS"
$AG_PiP_Name              = "AG-HICLASS-PUBLIC-IP"
$gipconfig_name           = "appGatewayIpConfig"
$fipconfig_name           = "appGwPublicFrontendIp"
$backendPool_name         = "TEST_Backend-Pool"
$PoolSettings_name        = "TEST88.hiclass.net-38080"
$HttpListener_name        = "TEST88.hiclass.net-http-listner"
$HttpsListener_name       = "TEST88.hiclass.net-https-listner"
$hostname                 = "TEST88.hiclass.net"
$hostname_http            = "TEST88.hiclass.net-http-rul"
$hostname_https           = "TEST88.hiclass.net-httsp-rul"
$frontendport_http_name   = "port_80"
$frontendport_https_name  = "port_443"

#[1] vnet 구하기
$vnet = Get-AzvirtualNetwork -Name $vnet_name -ResourceGroupName $resourceGroups
#[2] AG 서브넷 구하기
$AG_Subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $AG_Subnet_name
#[3] 공용 IP 이름 확인하기 : Get-AzPublicIPAddress -ResourceGroupName ISCREAM | select Name
#[4] 공용 IP 구하기
$pip = Get-AzPublicIPAddress -ResourceGroupName $resourceGroups -Name $AG_PiP_Name
#[5] AG 이름 확인하기 : Get-AzApplicationGateway -ResourceGroupName $resourceGroups | select Name
#[6] AG 구하기
$appgw = Get-AzApplicationGateway -ResourceGroupName $resourceGroups -Name $AG_name
#[7] AG Ipconfiguration 이름 확인하기: $appgw | Get-AzApplicationGatewayIPConfiguration
#[8] AG Ipconfiguration 구하기
$gipconfig = Get-AzApplicationGatewayIPConfiguration -Name $gipconfig_name -ApplicationGateway $appgw
#[9] AG Frontipconfiguraition 이름 확인하기 : $appgw | Get-AzApplicationGatewayFrontendIPConfig
#[10] AG Frontipconfiguraition 구하기
$fipconfig = Get-AzApplicationGatewayFrontendIPConfig -Name $fipconfig_name -ApplicationGateway $appgw
#[11] AG frontPort 이름 확인하기 : $appgw | Get-AzApplicationGatewayFrontendPort
#[12] AG frontendport 구하기
$frontendport_http = Get-AzApplicationGatewayFrontendPort -name $frontendport_http_name -ApplicationGateway $appgw
$frontendport_https = Get-AzApplicationGatewayFrontendPort -name $frontendport_https_name -ApplicationGateway $appgw

# 백엔드 풀 설정
$backendPool = Add-AzApplicationGatewayBackendAddressPool `
  -Name $backendPool_name -ApplicationGateway $appgw

# HTTP 설정에 추가할 정보 설정
$poolSettings = Add-AzApplicationGatewayBackendHttpSetting `
  -ApplicationGateway $appgw `
  -Name $PoolSettings_name `
  -Port 38080 `
  -Protocol Http `
  -CookieBasedAffinity Enabled `
  -RequestTimeout 30


### 리스너, 규칙 생성
#/ ** HTTP 리스너 ** /
$defaultlistener = Add-AzApplicationGatewayHttpListener `
  -Name $HttpListener_name `
  -Protocol Http `
  -FrontendIPConfiguration $fipconfig `
  -FrontendPort $frontendport_http `
  -HostName $hostname `
  -ApplicationGateway $appgw
# / ** HTTPS 리스너** /
# $httpslistner = Add-AzApplicationGatewayHttpListener `
#   -Name $HttpsListener_name `
#   -Protocol Https `
#   -FrontendIPConfiguration $fipconfig `
#   -FrontendPort $frontendport_https `
#   -HostName $hostname `
#   -ApplicationGateway $appgw

# 기본 수신기 가져오기(http :80)
# $defaultlistener = Get-AzApplicationGatewayHttpListener `
#   -Name $HttpListener_name -ApplicationGateway $appgw
#
# $httpslistner = Get-AzApplicationGatewayHttpListener `
#   -Name $HttpsListener_name -ApplicationGateway $appgw

# http rule 설정
Add-AzApplicationGatewayRequestRoutingRule `
  -ApplicationGateway $appgw `
  -Name $hostname_http `
  -RuleType Basic `
  -BackendHttpSettings $poolSettings `
  -HttpListener $defaultlistener `
  -BackendAddressPool $backendPool



# https rule 설정
# $appgw | Add-AzApplicationGatewayRequestRoutingRule `
#   -Name $hostname_https `
#   -RuleType Basic `
#   -HttpListener $httpslistner `
#   -BackendAddressPool $backendPool `
#   -BackendHttpSettings $poolSettings

# Application GW에 모든 설정 적용
Set-AzApplicationGateway -ApplicationGateway $appgw
