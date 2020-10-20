# 파워쉘을 이용하여 단독 리눅스 가상머신을 만든다.
# key 파일을 통해 리눅스 가상머신에 접속한다.
# ssh-keygen -m PEM -t rsa -b 4096
# Ref : https://docs.microsoft.com/ko-kr/azure/virtual-machines/linux/quick-create-powershell
################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################################################################
#                                   변수 설정                                    #
################################################################################
$VMLocalAdminUser           = "azureuser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString 'azureuser!@#123' -AsPlainText -Force
$location                   = "koreacentral"
$ResourceGroupName          = "webrtc"
$vnet_name                  = "webrtc_vnet"
$pip_name                   = "janus-PIP"
$nsg_name                   = "webrtc-NetworkSecurityGroup"
$nicName                    = "janus-NIC"
$HostName                   = "janus-VM"
$vmName                     = "janus-VM"
$vmSize                     = "Standard_DS3_v2"
$osDiskName                 = "janus-OS-DIsk"
$StorageAccountType         = "StandardSSD_LRS"
$AzAvailabilitySet_name     = "janus-Availbility-set"
$SourceAddressPrefix        = "175.208.212.79","112.223.14.90"

# 사용자 지정 스크립트 VM 생성 시 자동 실행
# $customConfig = @{
#     "fileUris" = (,"https://raw.githubusercontent.com/sohwaje/Powershell_for_azure/master/extensions/install.sh");
#     "commandToExecute" = "sudo sh install.sh"
# }
$customConfig = @{
    "fileUris" = (,"https://raw.githubusercontent.com/sohwaje/Powershell_for_azure/master/extensions/install.sh");
    "commandToExecute" = "sudo sh install.sh"
}

# vnet 가져오기
$vnet = Get-AzVirtualNetwork `
  -Name $vnet_name `
  -ResourceGroupName $ResourceGroupName

# Create a public IP address and specify a DNS name
$pip = New-AzPublicIpAddress `
  -ResourceGroupName $ResourceGroupName  `
  -Location $location `
  -AllocationMethod Static `
  -IdleTimeoutInMinutes 4 `
  -Name $pip_name

## NSG 만들기
# SSH rule 만들기
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig `
  -Name "SSH"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1000 `
  -SourceAddressPrefix $SourceAddressPrefix `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 16215 `
  -Access "Allow"

$nsgRulePro = New-AzNetworkSecurityRuleConfig `
  -Name "Prometheus"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1001 `
  -SourceAddressPrefix $SourceAddressPrefix `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 9090 `
  -Access "Allow"

$nsgRuleGrafana = New-AzNetworkSecurityRuleConfig `
  -Name "Grafana"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1002 `
  -SourceAddressPrefix $SourceAddressPrefix `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 3000 `
  -Access "Allow"

$nsgRuleTomcat = New-AzNetworkSecurityRuleConfig `
  -Name "Tomcat"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1003 `
  -SourceAddressPrefix $SourceAddressPrefix `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 8080 `
  -Access "Allow"

# NSG 생성
$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -Name $nsg_name `
  -SecurityRules $nsgRuleSSH,$nsgRulePro,$nsgRuleGrafana,$nsgRuleTomcat

# NIC 만들기
$nic = New-AzNetworkInterface `
  -Name $nicName `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -SubnetId $vnet.Subnets[0].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id

################################################################################
#                             가용성 집합 생성                                     #
################################################################################
$as = New-AzAvailabilitySet -ResourceGroupName $ResourceGroupName -Location $location `
  -Name $AzAvailabilitySet_name -Sku Aligned -PlatformFaultDomainCount 2 `
  -PlatformUpdateDomainCount 2

$cred = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword)

# Create a virtual machine configuration
$vmConfig = New-AzVMConfig `
  -VMName $vmName `
  -VMSize $vmSize `
  -AvailabilitySetId $as.Id
$vmConfig = Set-AzVMOperatingSystem `
  -VM $vmConfig `
  -Linux `
  -ComputerName $HostName `
  -Credential $cred `
  -DisablePasswordAuthentication
$vmConfig = Set-AzVMOSDisk `
  -VM $vmConfig `
  -Name $osDiskName `
  -CreateOption fromImage `
  -StorageAccountType $StorageAccountType
$vmconfig = Set-AzVMSourceImage `
  -VM $vmConfig `
  -PublisherName "OpenLogic" `
  -Offer "CentOS" `
  -Skus "7.7" `
  -Version "latest"
$vmconfig = Add-AzVMNetworkInterface `
  -VM $vmConfig `
  -Id $nic.Id
$vmconfig = Set-AzVMBootDiagnostic `
  -VM $vmconfig `
  -Disable

# Configure the SSH key
$sshPublicKey = cat ~/.ssh/id_rsa.pub     # local public key
Add-AzVMSshPublicKey `
  -VM $vmconfig `
  -KeyData $sshPublicKey `
  -Path "/home/azureuser/.ssh/authorized_keys"

# 가상머신을 생성하면서 가상머신 설정을 반영하기
New-AzVM `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -VM $vmConfig `
  -Verbose

Set-AzVMExtension `
 -ResourceGroupName $ResourceGroupName `
 -ExtensionName linux `
 -VMName $vmName `
 -Publisher Microsoft.Azure.Extensions `
 -Type "CustomScript" `
 -TypeHandlerVersion 2.1 `
 -Location $location `
 -Settings $customConfig

# IP 출력하기
Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $pip_name | select ipAddress

## SSH 접속
# ssh azureuser@IPaddress
