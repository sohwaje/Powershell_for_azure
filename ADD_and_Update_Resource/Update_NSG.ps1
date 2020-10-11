################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
<#
.Example
Get-AzNetworkSecurityGroup -ResourceGroupName "quiz_rg" -Name "quiz_server"
#>
$ResourceGroupName        = "quiz_rg"
$nsg_name                 = "quiz_server"
$SourceAddressPrefix      = "10.10.10.10","110.10.10.10","10.10.10.10"
$DestinationAddressPrefix = "10.3.1.0/24"
# rule 변경 시 변경할 rule의 이름
$rulename                 = "nodejs"
$Description              = "Allow nodejs"
$port                     = 3000
$Priority                 = 103
################################################################################
#                           기존 보안 그룹 업데이트                              #
################################################################################

# nsg 정보를 가져온다.
Write-Verbose "NSG 정보를 가져온다: $nsg_name"
$nsg = Get-AzNetworkSecurityGroup -Name $nsg_name -ResourceGroupName $ResourceGroupName

# 변경할 Inbound rule 작성
# rule을 변경할 때는 변경할 Rule Name을 지정한다.
Write-Verbose "업데이트 할 Rule을 설정한다: $rulename"
$nsg | Set-AzNetworkSecurityRuleConfig -Name $rulename -Description $Description `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority $Priority `
    -SourceAddressPrefix $SourceAddressPrefix -SourcePortRange * `
    -DestinationAddressPrefix $DestinationAddressPrefix -DestinationPortRange $port

# nsg를 업데이트한다.
Write-Verbose "NSG를 업데이트한다.: $nsg"
$nsg | Set-AzNetworkSecurityGroup
