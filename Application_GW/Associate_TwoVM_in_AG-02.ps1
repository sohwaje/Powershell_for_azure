################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
$VMLocalAdminUser           = "azureUser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString 'azureUser!@#123' -AsPlainText -Force
$location                   = "koreacentral"
$ResourceGroupName          = "ISCREAM"
$HostName                   = "TEST-VM"
$vmName                     = "TEST-VM"
$vmSize                     = "Standard_B1s"
$vnet_name                  = "Hi-Class"
$nicName                    = "TEST-VM-NIC"
$subnet_name                = "SEI-Subnet"
$StorageAccountType         = "Standard_LRS"
$ag_name                    = "AG-HICLASS"
$backendPool_name           = "TEST_Backend-Pool"
# 어플리케이션 이름 구하기
# Get-AzApplicationGateway -ResourceGroupName ISCREAM | select name
$appgw       = Get-AzApplicationGateway -ResourceGroupName $ResourceGroupName -Name $ag_name
# 백 엔드 풀 가져오기
$backendPool = Get-AzApplicationGatewayBackendAddressPool `
  -ApplicationGateway $appgw `
  -Name $backendPool_name
# vnet 가져오기
$vnet   = Get-AzVirtualNetwork -Name $vnet_name -ResourceGroupName $ResourceGroupName
# 서브넷 가져오기
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnet_name
# 가성머신 사용자 계정 및 패스워드 설정
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
# 프라이빗 고정 IP 구성
# $IpConfig1 = New-AzNetworkInterfaceIpConfig `
#   -Name $IpConfigName `
#   -SubnetId $vnet.Subnets[$subnetindex].Id `
#   -PrivateIpAddress $PrivateIpAddress
$customConfig = @{
    "fileUris" = (,"https://raw.githubusercontent.com/sohwaje/shell_scripts/master/httpd-install.sh");
    "commandToExecute" = "sudo sh httpd-install.sh"
}
for ($i=1; $i -le 2; $i++)
{
# nic 설정 가져오기
$nic = New-AzNetworkInterface `
  -Name testNIC$i `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -Subnet $subnet `
  -ApplicationGatewayBackendAddressPool $backendpool


# 가상머신 구성: 가상 머신 이름, 사이즈, 디스크 타입, OS 등
$VirtualMachine = New-AzVMConfig -VMName TestVM$i -VMSize $vmSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Linux -ComputerName TEST$i -Credential $Credential
$VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -Name testosdisk$i -CreateOption fromImage -StorageAccountType $StorageAccountType
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $nic.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'OpenLogic' -Offer 'CentOS' -Skus '7.7' -Version latest

# 가싱 머신 생성
New-AzVM `
 -ResourceGroupName $ResourceGroupName `
 -Location $location `
 -VM $VirtualMachine `
 -Verbose

Set-AzVMExtension `
 -ResourceGroupName $ResourceGroupName `
 -ExtensionName linux `
 -VMName TestVM$i `
 -Publisher Microsoft.Azure.Extensions `
 -Type "CustomScript" `
 -TypeHandlerVersion 2.1 `
 -Location $location `
 -Settings $customConfig
}
