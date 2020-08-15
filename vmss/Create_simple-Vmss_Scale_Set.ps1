# Ref = https://docs.microsoft.com/ko-kr/azure/virtual-machines/windows/tutorial-create-vmss
################################################################################
#                         자격 증명을 통해 Azure에 로그인                        #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 #####################################
$Location             = "koreacentral"
$ResourceGroupName    = "ISCREAM"
$VMScaleSetName       = "TEST-VM-ScaleSet"
$vnet_name            = "Hi-Class"
$subnet_name          = "SEI-Subnet"
$PublicIpAddressName  = "TEST-VM-PIP"
$LoadBalancerName     = "TEST-LB"

New-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -VMScaleSetName $VMScaleSetName `
  -VirtualNetworkName $vnet_name `
  -SubnetName $subnet_name `
  -PublicIpAddressName $PublicIpAddressName  `
  -LoadBalancerName $LoadBalancerName `
  -UpgradePolicyMode "Automatic"
