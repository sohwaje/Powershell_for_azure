################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
$ResourceGroupName            = "ISCREAM"
$location                     = "koreacentral"
$newAvailSetName              = "Availabilityset-TEST-VM"
################################################################################
#                               가용성 집합 만들기                                  #
################################################################################

New-AzAvailabilitySet `
   -Location $location `
   -Name $newAvailSetName `
   -ResourceGroupName $ResourceGroupName `
   -Sku aligned `
   -PlatformFaultDomainCount 2 `
   -PlatformUpdateDomainCount 5
