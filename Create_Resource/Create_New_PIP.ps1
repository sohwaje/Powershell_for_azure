################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 #####################################
$ResourceGroupName        = "ISCREAM"
$Location                 = "koreacentral"
$publicIpName             = "TEST10-PIP"

# Get-AzPublicIpAddress -Name myPublicIp*
################################################################################
#                           신규 공용 IP 생성                                   #
################################################################################
$publicIp = New-AzPublicIpAddress `
  -Name $publicIpName `
  -ResourceGroupName $ResourceGroupName `
  -AllocationMethod Static `
  -Location $Location

# VM의 공용 IP 확인
# Get-AzPublicIpAddress -ResourceGroupName "myResourceGroup" | Select "IpAddress"
