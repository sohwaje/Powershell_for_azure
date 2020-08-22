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
$VMLocalAdminUser           = "azureUser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString 'azureUser!@#123' -AsPlainText -Force
$location                   = "koreacentral"
$ResourceGroupName          = "ISCREAM"
$vnet_name                  = "Hi-Class"
$pip_name                   = "TEST-PIP"
$nsg_name                   = "TEST-NSG"
$nicName                    = "TEST-VM-NIC"
$HostName                   = "TEST-VM"
$vmName                     = "TEST-VM"
$vmSize                     = "Standard_D2s_v3"
$osDiskName                 = "TEST-OS-DIsk"
$StorageAccountType         = "Standard_LRS"

# 사용자 지정 스크립트 VM 생성 시 자동 실행
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
  -Name "TestSSHNSG"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1000 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 16215 `
  -Access "Allow"

$nsgRuleHTTP = New-AzNetworkSecurityRuleConfig `
  -Name "TestHTTPNSG"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1001 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 80 `
  -Access "Allow"

# NSG 생성
$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -Name $nsg_name `
  -SecurityRules $nsgRuleSSH,$nsgRuleHTTP

# NIC 만들기
$nic = New-AzNetworkInterface `
  -Name $nicName `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -SubnetId $vnet.Subnets[11].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id

# Define a credential object
# $securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword)

# Create a virtual machine configuration
$vmConfig = New-AzVMConfig `
  -VMName $vmName `
  -VMSize $vmSize
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

# Configure the SSH key
$sshPublicKey = cat ~/.ssh/id_rsa.pub
Add-AzVMSshPublicKey `
  -VM $vmconfig `
  -KeyData $sshPublicKey `
  -Path "/home/azureUser/.ssh/authorized_keys"

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
