################################################################################
#                         자격 증명을 통해 Azure에 로그인                            #
################################################################################
# Login-AzAccount
# Get-AzSubscription
# Set-AzContext -SubscriptionId "yourSubscriptionID"

################################################################################
#                                   변수 설정                                   #
################################################################################
$rgName = "ISCREAM"
$location = "koreacentral"
$AzRecoveryServicesVault_name = "hiclass-backup-recovery"
$backup_policy = "DefaultPolicy"
$vmName = "Front4-Hi-Class-Service"

## Azure Backup을 처음 사용하는 경우 다음과 같이 Register-AzResourceProvider를 사용하여 구독에서 Azure Recovery Service 공급자를 등록해야 한다.(이미 생성되어 있으면 pass)
# Register-AzResourceProvider -ProviderNamespace "Microsoft.RecoveryServices"

# Recovery Services 자격 증명 모음 만들기(이미 생성되어 있으면 pass)
# New-AzRecoveryServicesVault `
#     -ResourceGroupName $rgName `
#     -Name $AzRecoveryServicesVault_name `
#     -Location $location

# 자격 증명 모음 컨텍스트를 설정.
Get-AzRecoveryServicesVault `
    -Name $AzRecoveryServicesVault_name | Set-AzRecoveryServicesVaultContext

# 자격 증명 모음의 스토리지 중복 구성(LRS/GRS)을 변경합니다.(로컬/글로벌) => 여기서는 로컬(옵션:GeoRedundant/LocallyRedundant)
Get-AzRecoveryServicesVault `
    -Name $AzRecoveryServicesVault_name | Set-AzRecoveryServicesBackupProperty -BackupStorageRedundancy LocallyRedundant

### Azure VM에 백업 사용

# 백업 기본 정책 설정(없으면 DefaultPolicy)
$pol = Get-AzRecoveryServicesBackupProtectionPolicy -Name $backup_policy

# VM 백업을 사용하도록 설정 -> 정책, 리소스 그룹 및 VM 이름을 지정
Enable-AzRecoveryServicesBackupProtection `
    -Policy $pol `
    -ResourceGroupName $rgName `
    -Name $vmName

# 컨테이너를 지정하고, VM 정보를 가져오고, 백업을 실행
$backupcontainer = Get-AzRecoveryServicesBackupContainer `
    -ContainerType "AzureVM" `
    -FriendlyName $vmName

# 백업 아이템 이름(=가상머신 이름)
$item = Get-AzRecoveryServicesBackupItem `
    -Container $backupcontainer `
    -WorkloadType "AzureVM"

Backup-AzRecoveryServicesBackupItem -Item $item

# 백업 작업 모니터링
# Get-AzRecoveryservicesBackupJob
