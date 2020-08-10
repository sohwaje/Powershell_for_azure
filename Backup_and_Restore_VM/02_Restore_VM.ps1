################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"
$rgName                       = "ISCREAM"
$location                     = "koreacentral"
$AzRecoveryServicesVault_name = "hiclass-backup-recovery"
$backup_policy                = "DefaultPolicy"
$vmName                       = "Redis-Hi-Class-Service"
$StorageAccountName           = "diag976"
$newVM                        = "redis4"
$Availabilityset              = "Availabilityset-redis"
$vnet_name                    = "Hi-Class"
$nicName                      = "redis-nic4"
$destination_path             = "/Users/yusunglee/Downloads/Azure/vmconfig.json"
# azure portal에 서브넷 리스트의 순서
$subnetindex                  = 11
$PrivateIpAddress             = "10.1.11.8"
$IpConfigName1                = "IPConfig-1"

# 백업 관련 구독의 모든 자격 증명 모음
Get-AzRecoveryServicesVault

# 자격 증명 모음 컨텍스트 설정
Get-AzRecoveryServicesVault -Name $AzRecoveryServicesVault_name -ResourceGroupName $rgName | Set-AzRecoveryServicesVaultContext

# 자격증명 모음 ID를 가져와서 $targetVault.ID에 전달하기
$targetVault = Get-AzRecoveryServicesVault -ResourceGroupName $rgName -Name $AzRecoveryServicesVault_name
$targetVault.ID

# 자격 증명 모음에서 사용할 수 있는 보호 정책 확인
Get-AzRecoveryServicesBackupProtectionPolicy -WorkloadType "AzureVM" -VaultId $targetVault.ID

# 백업된 VM 선택
$namedContainer = Get-AzRecoveryServicesBackupContainer  -ContainerType "AzureVM" -Status "Registered" -FriendlyName $vmName -VaultId $targetVault.ID
$backupitem = Get-AzRecoveryServicesBackupItem -Container $namedContainer  -WorkloadType "AzureVM" -VaultId $targetVault.ID

# 복구 지점 선택: 변수 $rp는 지난 7 일간의 선택 된 백업 항목, $rp[0]은 최신 복구
$startDate = (Get-Date).AddDays(-7)
$endDate = Get-Date
$rp = Get-AzRecoveryServicesBackupRecoveryPoint -Item $backupitem -StartDate $startdate.ToUniversalTime() -EndDate $enddate.ToUniversalTime() -VaultId $targetVault.ID
$rp[0]


################################################################################
#                               비관리형 디스크 복원                                #
################################################################################
# $rp[0]이 이 디스크를 복원하는 데 사용할 복구 지점을 선택하여 스토리지에 저장한다.
# 여기서는 복원이 되는 것이 아니다. 스토리지에 4개의 파일이 저장된다. config, deploy, parameter, 디스크 이미지
$restorejob = Restore-AzRecoveryServicesBackupItem -RecoveryPoint $rp[0] `
 -StorageAccountName $StorageAccountName `
 -StorageAccountResourceGroupName $rgName `
 -VaultId $targetVault.ID
$restorejob

# 복원 작업이 완료될 떄까지 기다린다.
Wait-AzRecoveryServicesBackupJob -Job $restorejob -Timeout 43200

# 복원 작업이 완료되면 복원 작업의 세부 정보를 가져온다.
$restorejob = Get-AzRecoveryServicesBackupJob `
-Job $restorejob -VaultId $targetVault.ID
$details = Get-AzRecoveryServicesBackupJobDetails `
-Job $restorejob -VaultId $targetVault.ID

################################################################################
#                       구성 파일을 사용 하여 VM 만들기                              #
################################################################################
# 복원된 디스크 속성에서 작업 세부 정보를 쿼리합니다.
$properties          = $details.properties
$storageAccountName  = $properties["Target Storage Account Name"]
$configBlobName      = $properties["Config Blob Name"]
$containerName       = $properties["Config Blob Container Name"]
$configBlobUri       = $properties["Config Blob Uri"]
$templateBlobURI     = $properties["Template Blob Uri"]
$TargetResourceGroup = $properties["Target resource group"]

# Azure Storage 컨텍스트를 설정하고 JSON 구성 파일을 복원합니다.
Set-AzCurrentStorageAccount -Name $storageAccountName -ResourceGroupName $rgName
Get-AzStorageBlobContent -Container $containerName -Blob $configBlobName -Destination $destination_path -Force -Confirm:$false
$obj = ((Get-Content -Path $destination_path -Raw -Encoding Unicode)).TrimEnd([char]0x00) | ConvertFrom-Json

# JSON 구성 파일을 사용하여 VM 구성을 만듭니다.
$vm = New-AzVMConfig -VMSize $obj.'properties.hardwareProfile'.vmSize -VMName $newVM

# 관리 디스크 추가
Set-AzVMOSDisk -VM $vm -Name "osdisk" -VhdUri $obj.'properties.StorageProfile'.osDisk.vhd.Uri -CreateOption "Attach"
$vm.StorageProfile.OsDisk.OsType = $obj.'properties.StorageProfile'.OsDisk.OsType

# 네트워크 설정 지정
# $pip = New-AzPublicIpAddress -Name $nicName -ResourceGroupName $rgName -Location $location -AllocationMethod Static
$vnet           = Get-AzVirtualNetwork -Name $vnet_name -ResourceGroupName $rgName
$IpConfig1      = New-AzNetworkInterfaceIpConfig -Name $IpConfigName1 -SubnetId $vnet.Subnets[$subnetindex].Id -PrivateIpAddress $PrivateIpAddress -Primary
# $nic            = New-AzNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location -SubnetId $vnet.Subnets[$subnetindex].Id -IpConfiguration $IpConfig1
$nic            = New-AzNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location -IpConfiguration $IpConfig1
# $nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location -SubnetId $vnet.Subnets[$subnetindex].Id -PublicIpAddressId $pip.Id
$vm             = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id

# 가싱 머신 생성
New-AzVM -ResourceGroupName $rgName -Location $location -VM $vm -Verbose
# 관리형 디스크로 변환 : VM 할당 취소
Stop-AzVM -ResourceGroupName $rgName -Name $newVM -Force
# 관리형 디스크로 변환 : 변환
ConvertTo-AzVMManagedDisk -ResourceGroupName $rgName -VMName $newVM
