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
$location                   = "koreacentral"
$ResourceGroupName          = "ISCREAM"
$vnet_name                  = "Hi-Class"
$pip_name                   = "TEST-PIP"
$nsg_name                   = "TEST-NSG"
$nicName                    = "TEST-VM-NIC"
$HostName                   = "TEST-VM"
$vmName                     = "TEST-VM"
$vmSize                     = "Standard_B1s"
$osDiskName                 = "TEST-OS-DIsk"
$StorageAccountType         = "Standard_LRS"


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
  -DestinationPortRange 22 `
  -Access "Allow"

# NSG 생성
$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -Name $nsg_name `
  -SecurityRules $nsgRuleSSH

# NIC 만들기
$nic = New-AzNetworkInterface `
  -Name $nicName `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -SubnetId $vnet.Subnets[11].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id

# Define a credential object
$securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword)

# Create a virtual machine configuration
$vmConfig = New-AzVMConfig `
  -VMName $vmName `
  -VMSize $vmSize | `
Set-AzVMOperatingSystem `
  -Linux `
  -ComputerName $HostName `
  -Credential $cred `
  -DisablePasswordAuthentication | `
Set-AzVMOSDisk `
  -Name $osDiskName `
  -CreateOption fromImage `
  -StorageAccountType $StorageAccountType | `
Set-AzVMSourceImage `
  -PublisherName "Canonical" `
  -Offer "UbuntuServer" `
  -Skus "18.04-LTS" `
  -Version "latest" | `
Add-AzVMNetworkInterface `
  -Id $nic.Id

# Configure the SSH key
$sshPublicKey = cat ~/.ssh/id_rsa.pub
Add-AzVMSshPublicKey `
  -VM $vmconfig `
  -KeyData $sshPublicKey `
  -Path "/home/azureuser/.ssh/authorized_keys"

# 가상머신을 생성하면서 가상머신 설정을 반영하기
New-AzVM `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -VM $vmConfig

# IP 출력하기
Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $pip_name | select ipAddress

## SSH 접속
# ssh azureuser@IPaddress
