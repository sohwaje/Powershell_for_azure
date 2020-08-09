################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
################################# 변수 설정 ######################################
$VMLocalAdminUser           = "sigongweb"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "PASSWORD" -AsPlainText -Force
$location                   = "koreacentral"
$ResourceGroupName          = "ISCREAM"
$HostName                   = "MyVM"
$vmName                     = "MyVM"
$vmSize                     = "Standard_B1s"
$vnet_name                  = "Hi-Class"
$nicName                    = "MyNIC"
$subnetindex                = 11
$PrivateIpAddress           = "10.1.11.9"
$IpConfigName               = "IPConfig-MyVM"

# vnet 가져오기
$vnet           = Get-AzVirtualNetwork -Name $vnet_name -ResourceGroupName $ResourceGroupName
# 프라이빗 고정 IP 구성
$IpConfig1      = New-AzNetworkInterfaceIpConfig -Name $IpConfigName -SubnetId $vnet.Subnets[$subnetindex].Id -PrivateIpAddress $PrivateIpAddress -Primary
# nic에 프라이빗 고정 IP 할당
$nic            = New-AzNetworkInterface -Name $nicName -ResourceGroupName $ResourceGroupName -Location $location -IpConfiguration $IpConfig1
# 가성머신 사용자 계정 및 패스워드 설정
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

# 가상머신 구성: 가상 머신 이름, 사이즈, OS 등
$VirtualMachine = New-AzVMConfig -VMName $vmName -VMSize $vmSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Linux -ComputerName $HostName -Credential $Credential
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $nic.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'OpenLogic' -Offer 'CentOS' -Skus '7.7' -Version latest

# 가싱 머신 생성 : for문을 이용해 2개의 가상 머신을 생성한다.
New-AzVM `
 -ResourceGroupName $ResourceGroupName `
 -Location $location `
 -VM $VirtualMachine `
 -Verbose
