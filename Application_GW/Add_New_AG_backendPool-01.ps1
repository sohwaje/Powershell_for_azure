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
$hostname_http            = "TEST88.hiclass.net-http-rule"
$hostname_https           = "TEST88.hiclass.net-httsp-rule"
$frontendport_http_name   = "port_80"
$frontendport_https_name  = "port_443"
$cert                     = "hiclassnet"
$probe_name               = "TEST88.hiclass.net-probe"

#[1] vnet 구하기
Write-Verbose "vnet 정보 가져오기: $vnet_name"
$vnet = Get-AzvirtualNetwork -Name $vnet_name -ResourceGroupName $resourceGroups
#[2] AG 서브넷 구하기
Write-Verbose "Subnet 정보 가져오기: $AG_Subnet_name"
$AG_Subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $AG_Subnet_name
#[3] 공용 IP 이름 확인하기 : Get-AzPublicIPAddress -ResourceGroupName ISCREAM | select Name
#[4] 공용 IP 구하기
Write-Verbose "공용 IP 정보 가져오기: $AG_PiP_Name"
$pip = Get-AzPublicIPAddress -ResourceGroupName $resourceGroups -Name $AG_PiP_Name
#[5] AG 이름 확인하기 : Get-AzApplicationGateway -ResourceGroupName $resourceGroups | select Name
#[6] AG 구하기
Write-Verbose "애플리케이션 정보 가져오기: $AG_name"
$appgw = Get-AzApplicationGateway -ResourceGroupName $resourceGroups -Name $AG_name
#[7] AG Ipconfiguration 이름 확인하기: $appgw | Get-AzApplicationGatewayIPConfiguration
#[8] AG Ipconfiguration 구하기
Write-Verbose "애플리케이션 게이트웨이 IP 구성 정보 가져오기: $gipconfig_name"
$gipconfig = Get-AzApplicationGatewayIPConfiguration -Name $gipconfig_name -ApplicationGateway $appgw
#[9] AG Frontipconfiguraition 이름 확인하기 : $appgw | Get-AzApplicationGatewayFrontendIPConfig
#[10] AG Frontipconfiguraition 구하기
Write-Verbose "애플리케이션 프론트 게이트웨이 IP 구성 정보 가져오기: $fipconfig_name"
$fipconfig = Get-AzApplicationGatewayFrontendIPConfig -Name $fipconfig_name -ApplicationGateway $appgw
#[11] AG frontPort 이름 확인하기 : $appgw | Get-AzApplicationGatewayFrontendPort
#[12] AG frontendport 구하기
Write-Verbose "애플리케이션 게이트웨이 Front HTTP Port 정보 가져오기: $frontendport_http_name"
$frontendport_http = Get-AzApplicationGatewayFrontendPort -name $frontendport_http_name -ApplicationGateway $appgw
Write-Verbose "애플리케이션 게이트웨이 Front HTTPS Port 정보 가져오기: $frontendport_http_name"
$frontendport_https = Get-AzApplicationGatewayFrontendPort -name $frontendport_https_name -ApplicationGateway $appgw

# 백 엔드 풀 설정
Write-Verbose "백 엔드 풀 설정 추가하기: $backendPool_name"
$appgw = Add-AzApplicationGatewayBackendAddressPool `
  -ApplicationGateway $appgw `
  -Name $backendPool_name
Write-Verbose "백 엔드 풀 정보 가져오기: $backendPool_name"
# 백 엔드 풀 가져오기
$backendPool = Get-AzApplicationGatewayBackendAddressPool `
  -ApplicationGateway $appgw `
  -Name $backendPool_name

# http probe 설정
Write-Verbose "HTTP Probe 설정 추가: $probe_name"
$appgw = Add-AzApplicationGatewayProbeConfig `
  -ApplicationGateway $appgw `
  -Name $probe_name `
  -Protocol Http `
  -HostName $hostname -Path "/" -Interval 30 -Timeout 120 -UnhealthyThreshold 8
Write-Verbose "HTTP Probe 설정 가져오기: $probe_name"
$probe = Get-AzApplicationGatewayProbeConfig `
  -ApplicationGateway $appgw `
  -Name $probe_name

# HTTP 설정
Write-Verbose "HTTP 설정 추가하기: $PoolSettings_name"
$appgw = Add-AzApplicationGatewayBackendHttpSetting `
  -ApplicationGateway $appgw `
  -Name $PoolSettings_name `
  -Port 38080 `
  -Protocol Http `
  -CookieBasedAffinity Enabled `
  -RequestTimeout 30 `
  -Probe $probe
Write-Verbose "HTTP 설정 가져오기: $PoolSettings_name"
$poolSettings = Get-AzApplicationGatewayBackendHttpSetting `
  -ApplicationGateway $appgw `
  -Name $PoolSettings_name

# HTTP 리스너 설정
Write-Verbose "HTTP 수신기 추가하기: $HttpListener_name"
$appgw = Add-AzApplicationGatewayHttpListener `
  -ApplicationGateway $appgw `
  -Name $HttpListener_name `
  -Protocol Http `
  -FrontendIPConfiguration $fipconfig `
  -FrontendPort $frontendport_http `
  -HostName $hostname
# HTTP 리스너 가져오기
Write-Verbose "HTTP 수신기 가져오기: $HttpListener_name"
$defaultlistener = Get-AzApplicationGatewayHttpListener `
  -ApplicationGateway $appgw `
  -Name $HttpListener_name
# SSL/TLS 인증서 가져오기
Write-Verbose "SSL/TLS 인증서 가져오기: $HttpListener_name"
$SslCertificate = Get-AzApplicationGatewaySslCertificate -ApplicationGateway $appgw -Name $cert
# HTTPS 리스너 설정 $httpslistner
Write-Verbose "HTTPS 수신기 추가하기: $HttpsListener_name"
$appgw = Add-AzApplicationGatewayHttpListener `
  -ApplicationGateway $appgw `
  -Name $HttpsListener_name `
  -Protocol Https `
  -FrontendIPConfiguration $fipconfig `
  -FrontendPort $frontendport_https `
  -SslCertificate $SslCertificate `
  -HostName $hostname
# HTTPS 리스너 가져오기
Write-Verbose "HTTPS 수신기 가져오기: $HttpListener_name"
$httpslistner = Get-AzApplicationGatewayHttpListener `
  -Name $HttpsListener_name -ApplicationGateway $appgw

# http rule 설정
Write-Verbose "HTTP Rule 추가하기: $hostname_http"
$appgw = Add-AzApplicationGatewayRequestRoutingRule `
  -ApplicationGateway $appgw `
  -Name $hostname_http `
  -RuleType Basic `
  -BackendHttpSettings $poolSettings `
  -HttpListener $defaultlistener `
  -BackendAddressPool $backendPool

# https rule 설정
Write-Verbose "HTTPS Rule 추가하기: $hostname_http"
$appgw = Add-AzApplicationGatewayRequestRoutingRule `
  -ApplicationGateway $appgw `
  -Name $hostname_https `
  -RuleType Basic `
  -HttpListener $httpslistner `
  -BackendAddressPool $backendPool `
  -BackendHttpSettings $poolSettings

# Application GW에 모든 설정 적용
Write-Verbose "모든 설정을 애플리케이션 게이트웨이에 적용하기: $appgw"
Set-AzApplicationGateway -ApplicationGateway $appgw
