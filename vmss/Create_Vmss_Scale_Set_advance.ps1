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
$TAG                  = "-ys"

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

# Create public IP : 이름은 소문자만 가능
$PIP = New-AzPublicIpAddress -Force `
  -Name ("pip" + $TAG) `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -AllocationMethod Static `
  -DomainNameLabel ("pip" + $TAG)
$PIP = Get-AzPublicIpAddress `
  -Name ("pip"  + $TAG) `
  -ResourceGroupName $ResourceGroupName

# Create LoadBalancer
$FrontendName = "fe" + $TAG
$BackendAddressPoolName = "bepool" + $TAG
$ProbeName = "vmssprobe" + $TAG
$InboundNatPoolName  = "innatpool" + $TAG
$LBRuleName = "lbrule" + $TAG
$LBName = "Testvmsslb" + $TAG

$Frontend = New-AzLoadBalancerFrontendIpConfig -Name $FrontendName -PublicIpAddress $PIP
$BackendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $BackendAddressPoolName
$Probe = New-AzLoadBalancerProbeConfig -Name $ProbeName -RequestPath / `
  -Protocol http `
  -Port 80 `
  -IntervalInSeconds 15 `
  -ProbeCount 2
$InboundNatPool = New-AzLoadBalancerInboundNatPoolConfig -Name $InboundNatPoolName  -FrontendIPConfigurationId `
    $Frontend.Id -Protocol Tcp -FrontendPortRangeStart 3360 -FrontendPortRangeEnd 3362 -BackendPort 3370
$LBRule = New-AzLoadBalancerRuleConfig -Name $LBRuleName `
    -FrontendIPConfiguration $Frontend -BackendAddressPool $BackendAddressPool `
    -Probe $Probe -Protocol Tcp -FrontendPort 80 -BackendPort 80 `
    -IdleTimeoutInMinutes 15 -EnableFloatingIP -LoadDistribution SourceIP
$ActualLb = New-AzLoadBalancer -Name $LBName -ResourceGroupName $ResourceGroupName -Location $location `
    -FrontendIpConfiguration $Frontend -BackendAddressPool $BackendAddressPool `
    -Probe $Probe -LoadBalancingRule $LBRule -InboundNatPool $InboundNatPool
$ExpectedLb = Get-AzLoadBalancer -Name $LBName -ResourceGroupName $ResourceGroupName


# New VMSS Parameters
$VMSSName = "VMSS" + $ResourceGroupName;
$AdminUsername = "azureUser";
$AdminPassword = "azureUser@123" + $ResourceGroupName;
$PublisherName = "OpenLogic"
$Offer         = "CentOS"
$Skus          = "7.7"
$Version       = "latest"
$VHDContainer = "https://" + $StorageName + ".blob.core.contoso.net/" + $VMSSName;
# $ExtName = "CSETest";
# $Publisher = "Microsoft.Compute";
# $ExtType = "BGInfo";
# $ExtVer = "2.1";


#IP Config for the NIC
$IPCfg = New-AzVmssIPConfig -Name "VMss-Test" `
    -LoadBalancerInboundNatPoolsId $ExpectedLb.InboundNatPools[0].Id `
    -LoadBalancerBackendAddressPoolsId $ExpectedLb.BackendAddressPools[0].Id `
    -SubnetId $SubnetID;

#VMSS Config
$VMSS = New-AzVmssConfig -Location $location -SkuCapacity 2 -SkuName "Standard_B1ms" -UpgradePolicyMode "Automatic" `
    | Add-AzVmssNetworkInterfaceConfiguration -Name "Test-vmssNICconfig" -Primary $True -IPConfiguration $IPCfg `
    | Add-AzVmssNetworkInterfaceConfiguration -Name "Test2-vmssNICconfig"  -IPConfiguration $IPCfg `
    | Set-AzVmssOSProfile -ComputerNamePrefix "Test-vmssProfile"  -AdminUsername $AdminUsername -AdminPassword $AdminPassword `
    | Set-AzVmssStorageProfile -Name "Test-StorageProfile"  -OsDiskCreateOption 'FromImage' -OsDiskCaching "None" `
    -ImageReferenceOffer $Offer -ImageReferenceSku $Skus -ImageReferenceVersion $Version `
    -ImageReferencePublisher $PublisherName -VhdContainer $VHDContainer `
    | Add-AzVmssExtension -Name $ExtName -Publisher $Publisher -Type $ExtType -TypeHandlerVersion $ExtVer -AutoUpgradeMinorVersion $True

#Create the VMSS
New-AzVmss -ResourceGroupName $ResourceGroupName -Name $VMSSName -VirtualMachineScaleSet $VMSS;
