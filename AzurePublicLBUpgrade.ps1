<#PSScriptInfo

.VERSION 4.0

.GUID 803f6271-accf-413f-83b9-4388aba6b448

.AUTHOR Microsoft Corporation

.COMPANYNAME Microsoft Corporation

.COPYRIGHT Microsoft Corporation. All rights reserved.

.TAGS Azure, Az, LoadBalancer, AzNetworking

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<#

.DESCRIPTION
This script will help you create a Standard SKU Public load balancer with the same configuration as your Basic SKU load balancer.

.PARAMETER oldRgName
Name of ResourceGroup of Basic Public Load Balancer, like "microsoft_rg1"
.PARAMETER oldLBName
Name of Basic Public Load Balancer you want to upgrade.
.PARAMETER newLBName
Name of the newly created Standard Public Load Balancer.

.EXAMPLE
./AzureLBUpgrade.ps1 -oldRgName "test_publicUpgrade_rg" -oldLBName "LBForPublic" -newLbName "LBForUpgrade"
./AzurePublicLBUpgrade.ps1 -oldRgName "C-TFT" -oldLBName "istool-web-lb" -newLbName "istool-lb"  
.LINK
https://aka.ms/upgradeloadbalancerdoc
https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-overview/

.NOTES
Note - all paramemters are required in order to successfully create a Standard Public Load Balancer.
#>
#>
##User defined paramters
#Parameters for specified Basic Load Balancer
Param(
[Parameter(Mandatory = $True)][string] $oldRgName,
[Parameter(Mandatory = $True)][string] $oldLBName,
#Parameters for new Standard Load Balancer
[Parameter(Mandatory = $True)][string] $newLBName
)

#getting current loadbalancer
$lb = Get-AzLoadBalancer -ResourceGroupName $oldRgName -Name $oldLBName

$newRgName = $oldRgName
$newlocation = $lb.location

##collaspe #1 and #2 into one loop for each frontend config
$newlbFrontendConfigs = $lb.FrontendIpConfigurations
$feProcessed = 1

#Adding variable for PIP Names
$pipCount=1

$continue = "no"
#pre-req check
$newlbFrontendConfigsCheck = $lb.FrontendIpConfigurations
foreach ($frontEndConfig in $newlbFrontendConfigsCheck)
{
    #1. get existing Public IP
    $pipName = (($frontEndConfig.publicIpAddress).id).Split("/")[8]
    $pipRG = (($frontEndConfig.publicIpAddress).id).Split("/")[4]
    $pip = Get-AzPublicIpAddress -Name $pipName -ResourceGroupName $pipRG
    $pip.PublicIpAllocationMethod
    if ($pip.PublicIpAllocationMethod -eq 'Dynamic')
    {
        Write-Host "Please update to Static IP"
        #break
        exit
    }
    else
    {
        $continue = "yes"
    }

}

if ($continue -eq "yes")
{
    ## create new lb
    $newlb = New-AzLoadBalancer -ResourceGroupName $newRgName -Name $newLbName -SKU Standard -Location $newlocation
}

$newlbFrontendConfigs = $lb.FrontendIpConfigurations
$feProcessed = 1

foreach ($frontEndConfig in $newlbFrontendConfigs)
{
    #1. get existing Public IP
    $pipName = (($frontEndConfig.publicIpAddress).id).Split("/")[8]
    $pipRG = (($frontEndConfig.publicIpAddress).id).Split("/")[4]
    $pip = Get-AzPublicIpAddress -Name $pipName -ResourceGroupName $pipRG
    $pip.PublicIpAllocationMethod
    if ($pip.PublicIpAllocationMethod -eq 'Dynamic')
    {
        Write-Host "Please update to Static IP"
        #break
        exit
    }
    $pip.Sku.Name = 'Standard'
    Set-AzPublicIpAddress -PublicIpAddress $pip

    ## Assigning temporarily an empty IP
    $frontEndConfig.PublicIpAddress = $null
    $basicPIP = New-AzPublicIpAddress -Name ($pipName + "-basic") -ResourceGroupName $pipRG -Location $pip.location -AllocationMethod static
    #$lb.FrontendIpConfigurations[0].PublicIpAddress = $null
    $frontEndConfig.PublicIpAddress = $basicPIP
    $lb | set-AzLoadBalancer

    $lb = Get-AzLoadBalancer -ResourceGroupName $oldRgName -Name $oldLBName


    $pipCheck = Get-AzPublicIpAddress -Name $pipName -ResourceGroupName $pipRG
    if ($pipCheck.Sku.Name -eq "Standard")
    {
        #2. create frontend config
        $newFrontEndConfigName = $frontEndConfig.Name

        ##Updating PIP ID
        #$newPIPIpConfigId = ($pipCheck.IpConfiguration.Id).split("/")[0] + "/" + ($pipCheck.IpConfiguration.Id).split("/")[1] + "/" + ($pipCheck.IpConfiguration.Id).split("/")[2]+ "/" + ($pipCheck.IpConfiguration.Id).split("/")[3]+ "/" + ($pipCheck.IpConfiguration.Id).split("/")[4]+ "/" + ($pipCheck.IpConfiguration.Id).split("/")[5] +"/" + ($pipCheck.IpConfiguration.Id).split("/")[6] + "/" + ($pipCheck.IpConfiguration.Id).split("/")[7] + "/" + $newLBName + "/" + ($pipCheck.IpConfiguration.Id).split("/")[9] + "/" + ($pipCheck.IpConfiguration.Id).split("/")[10]
        #$pipCheck.IpConfiguration.Id = $newPIPIpConfigId
        #Set-AzPublicIpAddress -PublicIpAddress $pip
        #New-Variable -Name "frontEndIpConfig$feProcessed" -Value (New-AzLoadBalancerFrontendIpConfig -Name $newFrontEndConfigName -PublicIpAddress $pipCheck)
        $newlb | Add-AzLoadBalancerFrontendIpConfig -Name $newFrontEndConfigName -PublicIpAddress $pipCheck | Set-AzLoadBalancer
    }

    else
    {
        Write-Host "Please check settings"
    }
    $feProcessed++
    $pipCount++

}
#$rulesFrontEndIpConfig = (Get-Variable -Include frontEndIpConfig*)

#3. create inbound nat rule configs
$newlbNatRules = $lb.InboundNatRules
##looping through NAT Rules
$ruleprocessed = 1
foreach ($natRule in $newlbNatRules)
{
    ##need to get correct frontendipconfig
    $frontEndName = (($natRule.FrontendIPConfiguration).id).Split("/")[10]
    #$frontEndNameConfig = ((Get-Variable -Include frontEndIpConfig* | Where-Object {$_.Value.name -eq $frontEndName})).value
    $frontEndNameConfig = Get-AzLoadBalancerFrontendIpConfig -LoadBalancer $newLb -Name $frontEndName
# New-Variable -Name "nat$ruleprocessed" -Value (New-AzLoadBalancerInboundNatRuleConfig -Name $natRule.name -FrontendIpConfiguration $frontEndNameConfig -Protocol $natRule.Protocol -FrontendPort $natRule.FrontendPort -BackendPort $natRule.BackendPort)
# $slb | Add-AzLoadBalancerInboundNatRuleConfig -Name "NewNatRule" -FrontendIPConfiguration $slb.FrontendIpConfigurations[0] -Protocol "Tcp" -FrontendPort 3350 -BackendPort 3350 -EnableFloatingIP
    $newlb | Add-AzLoadBalancerInboundNatRuleConfig -Name $natRule.name -FrontendIpConfiguration $frontEndNameConfig -Protocol $natRule.Protocol -FrontendPort $natRule.FrontendPort -BackendPort $natRule.BackendPort
    $ruleprocessed++
    $newlb | Set-AzLoadBalancer
}


#geting LB now after ceation
$newlb = (Get-AzLoadBalancer  -ResourceGroupName $newrgName -Name $newLbName)

#5. create probe config
$newProbes = Get-AzLoadBalancerProbeConfig -LoadBalancer $lb
foreach ($probe in $newProbes)
{
    $probeName = $probe.name
    $probeProtocol = $probe.protocol
    $probePort = $probe.port
    $probeInterval = $probe.intervalinseconds
    $probeRequestPath = $probe.requestPath
    $probeNumbers = $probe.numberofprobes
    $newlb | Add-AzLoadBalancerProbeConfig -Name $probeName -RequestPath $probeRequestPath -Protocol $probeProtocol -Port $probePort -IntervalInSeconds $probeInterval -ProbeCount $probeNumbers
    $newlb | Set-AzLoadBalancer
}

#6. create backend pools
##
$backendArray=@()
$newBackendPools = $lb.BackendAddressPools
## needs a loop to address multiple pools
foreach ($newBackendPool in $newBackendPools)
{
    ##
    $existingBackendPoolConfig = Get-AzLoadBalancerBackendAddressPoolConfig -LoadBalancer $lb -Name ($newBackendPool).Name
    $newlb | Add-AzLoadBalancerBackendAddressPoolConfig -Name ($newBackendPool).Name | Set-AzLoadBalancer
    ##
    $newlb = (Get-AzLoadBalancer  -ResourceGroupName $newrgName -Name $newLbName)
    #$newBackendPoolConfig
    $nics = (($lb.BackendAddressPools) | Where-Object {$_.Name -eq ($newBackendPool).name}).BackendIpConfigurations
    foreach ($nic in $nics)
    {
        $nicRG = $nic.id.Split("/")[4]
        $nicToAdd = Get-AzNetworkInterface -name ($nic.id).Split("/")[8] -ResourceGroupName $nicRG
        #write-host "Reconfiguring $nicToAdd.Name"
        $nicToAdd.IpConfigurations[0].LoadBalancerBackendAddressPools = $null
        $nicToAdd.IpConfigurations[0].LoadBalancerInboundNatRules = $null
        Set-AzNetworkInterface -NetworkInterface $nicToAdd
        $backendArray += ($newBackendPool).Name +"," + ($nicToAdd).id
    }
}

#6b. Re-adding NICs to backend pool
foreach ($backendItem in $backendArray)
{
    $newlb = (Get-AzLoadBalancer  -ResourceGroupName $newrgName -Name $newLbName)
    $lbBackend = Get-AzLoadBalancerBackendAddressPoolConfig -name ($backendItem.Split(",")[0]) -LoadBalancer $newlb
    #write-host "nic"
    $nicRG = $nic.id.Split("/")[4]
    $nicToAssociate = Get-AzNetworkInterface -name (($backendItem.Split(",")[1]).split("/")[8]) -resourcegroupname $nicRG
    #$nicToAssociate
    $nicToAssociate.IpConfigurations[0].LoadBalancerBackendAddressPools = $lbBackend
    Set-AzNetworkInterface -NetworkInterface $nicToAssociate
}

$newlb = (Get-AzLoadBalancer  -ResourceGroupName $newrgName -Name $newLbName)


$newlb = (Get-AzLoadBalancer  -ResourceGroupName $newrgName -Name $newLbName)
#7. create load balancer rule config
$newLbRuleConfigs = Get-AzLoadBalancerRuleConfig -LoadBalancer $lb
foreach ($newLbRuleConfig in $newLbRuleConfigs)
{
    #$j = 1
    $backendPool = (Get-AzLoadBalancerBackendAddressPoolConfig -LoadBalancer $newlb -Name ((($newLbRuleConfig.BackendAddressPool.id).split("/"))[10]))
    $lbFrontEndName = (($newLbRuleConfig.FrontendIPConfiguration).id).Split("/")[10]
    $lbFrontEndNameConfig = (Get-AzLoadBalancerFrontendIpConfig -Name $lbFrontEndName -LoadBalancer $newlb)
    $newlb | Add-AzLoadBalancerRuleConfig -Name ($newLbRuleConfig).Name -FrontendIPConfiguration $lbFrontEndNameConfig -BackendAddressPool $backendPool -Probe (Get-AzLoadBalancerProbeConfig -LoadBalancer $newlb -Name (($newLbRuleConfig.Probe.id).split("/")[10])) -Protocol ($newLbRuleConfig).protocol -FrontendPort ($newLbRuleConfig).FrontendPort -BackendPort ($newLbRuleConfig).BackendPort -IdleTimeoutInMinutes ($newLbRuleConfig).IdleTimeoutInMinutes -LoadDistribution SourceIP -DisableOutboundSNAT # -EnableFloatingIP
    $newlb | set-AzLoadBalancer
    #$outboundRule = New-AzLoadBalancerOutBoundRuleConfig -Name "outbound$j" -FrontendIPConfiguration $lbFrontEndNameConfig -BackendAddressPool $lbFrontEndNameConfig -Protocol ($newLbRuleConfig).protocol -IdleTimeoutInMinutes 15 -AllocatedOutboundPort 10000
    #$j++
}
$newlb = (Get-AzLoadBalancer  -ResourceGroupName $newrgName -Name $newLbName)
#$outboundRule = New-AzLoadBalancerOutBoundRuleConfig -Name "Outboundrule" -FrontendIPConfiguration $outboundFrontEndPool -BackendAddressPool $outboundBackendPool -Protocol All -IdleTimeoutInMinutes 15 -AllocatedOutboundPort 10000
$newlb | Add-AzLoadBalancerOutboundRuleConfig -Name "Outboundrule" -FrontendIPConfiguration $outboundFrontEndPool -BackendAddressPool $outboundBackendPool -Protocol All -IdleTimeoutInMinutes 15 -AllocatedOutboundPort 10000
#$newlb | Set-AzLoadBalancerOutboundRuleConfig -Name "Outboundrule" -FrontendIPConfiguration $outboundFrontEndPool -BackendAddressPool $outboundBackendPool -Protocol All -IdleTimeoutInMinutes 15 -AllocatedOutboundPort 10000
$newlb | set-AzLoadBalancer
