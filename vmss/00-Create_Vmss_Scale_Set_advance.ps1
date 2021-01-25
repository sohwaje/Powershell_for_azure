# Ref = https://docs.microsoft.com/ko-kr/azure/virtual-machines/windows/tutorial-create-vmss
################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 #####################################
$Location             = "koreacentral"
$ResourceGroupName    = "ISCREAM"
$vnet_name            = "Hi-Class"
$subnet_name          = "SEI-Subnet"
$TAG                  = "-gaudium"

#Vnet, Subnet
$vnet = Get-AzVirtualNetwork -Name $vnet_name -ResourceGroupName $ResourceGroupName
$SubnetID = $vnet.Subnets[11].Id
# Storage
$StorageName    = "diag976"  # 소문자만 가능
$StorageType    = "Standard_LRS"
# New-AzStorageAccount `
#   -ResourceGroupName $ResourceGroupName `
#   -Name $StorageName `
#   -Location $Location `
#   -Type $StorageType
# $StorageAccount = Get-AzStorageAccount `
#   -ResourceGroupName $ResourceGroupName `
#   -Name $StorageName;

# 공용 IP 주소를 만든다: 이름은 소문자만 가능
$PIP = New-AzPublicIpAddress -Force `
  -Name ("pip" + $TAG) `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -AllocationMethod Static `
  -DomainNameLabel ("pip" + $TAG)
$PIP = Get-AzPublicIpAddress `
  -Name ("pip"  + $TAG) `
  -ResourceGroupName $ResourceGroupName

# 로드밸런서를 만들 때 필요한 변수 선언
$FrontendName = "fe" + $TAG
$BackendAddressPoolName = "bepool" + $TAG
$ProbeName = "vmssprobe" + $TAG
$InboundNatPoolName  = "innatpool" + $TAG
$LBRuleName = "lbrule" + $TAG
$LBName = "testvmsslb" + $TAG

# 프런트 엔드 IP 구성을 만든다.
################################################################################
$Frontend = New-AzLoadBalancerFrontendIpConfig -Name $FrontendName -PublicIpAddress $PIP
# 백 엔드 주소 풀 구성을 만든다.
################################################################################
$BackendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $BackendAddressPoolName
# 상태 프로브 만들기
################################################################################
$Probe = New-AzLoadBalancerProbeConfig -Name $ProbeName -RequestPath / `
  -Protocol http `
  -Port 80 `
  -IntervalInSeconds 15 `
  -ProbeCount 2
$InboundNatPool = New-AzLoadBalancerInboundNatPoolConfig -Name $InboundNatPoolName `
  -FrontendIPConfigurationId $Frontend.Id `
  -Protocol Tcp `
  -FrontendPortRangeStart 50000 -FrontendPortRangeEnd 50004 -BackendPort 16215
$LBRule = New-AzLoadBalancerRuleConfig -Name $LBRuleName `
    -FrontendIPConfiguration $Frontend -BackendAddressPool $BackendAddressPool `
    -Probe $Probe -Protocol Tcp -FrontendPort 80 -BackendPort 80 `
    -IdleTimeoutInMinutes 15 -EnableFloatingIP -LoadDistribution SourceIP
$ActualLb = New-AzLoadBalancer -Name $LBName -ResourceGroupName $ResourceGroupName -Location $location `
    -FrontendIpConfiguration $Frontend -BackendAddressPool $BackendAddressPool `
    -Probe $Probe -LoadBalancingRule $LBRule -InboundNatPool $InboundNatPool
$ExpectedLb = Get-AzLoadBalancer -Name $LBName -ResourceGroupName $ResourceGroupName


# New VMSS Parameters
$VMSSName = "vmss" + $TAG
$AdminUsername = "azureUser";
$AdminPassword = "azureUser!@#123" + $TAG
$PublisherName = "OpenLogic"
$Offer         = "CentOS"
$Skus          = "7.7"
$Version       = "latest"
$VHDContainer = "https://" + $StorageName + ".blob.core.windows.net/" + $VMSSName;
# VMSS에 사용자 지정 스크립트 설치 : OS 초기에 필요한 설치를 스크립트를 통해 진행할 수 있다.
# VMSS에 사용자 지정 스크립트는 한 번에 하나만 적용할 수 있다. 추가 적용은 기존 스크립트를 삭제하고 재적용 해야 한다.
$ExtName = "InitialSettings";
$Publisher = "Microsoft.Azure.Extensions";
$ExtType = "customScript";
$ExtVer = "2.1";


#IP Config for the NIC
$IPCfg = New-AzVmssIPConfig -Name "VMss-Test" `
    -LoadBalancerInboundNatPoolsId $ExpectedLb.InboundNatPools[0].Id `
    -LoadBalancerBackendAddressPoolsId $ExpectedLb.BackendAddressPools[0].Id `
    -SubnetId $SubnetID;


#VMSS Config
$VMSS = New-AzVmssConfig -Location $location -SkuCapacity 2 -SkuName "Standard_DS1_v2" -UpgradePolicyMode "Automatic" `
    | Add-AzVmssNetworkInterfaceConfiguration -Name "test-vmssNICconfig" -Primary $True -IPConfiguration $IPCfg `
    | Set-AzVmssOSProfile -ComputerNamePrefix "test-vmssProfile" -AdminUsername $AdminUsername -AdminPassword $AdminPassword `
    | Set-AzVmssStorageProfile -Name "test-StorageProfile"  -OsDiskCreateOption 'FromImage' -OsDiskCaching "None" `
    -ImageReferenceOffer $Offer -ImageReferenceSku $Skus -ImageReferenceVersion $Version `
    -ImageReferencePublisher $PublisherName -VhdContainer $VHDContainer `
    | Add-AzVmssExtension -Name $ExtName -Publisher $Publisher -Type $ExtType -TypeHandlerVersion $ExtVer -AutoUpgradeMinorVersion $True

#Create the VMSS
New-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -Name $VMSSName `
  -VirtualMachineScaleSet $VMSS
