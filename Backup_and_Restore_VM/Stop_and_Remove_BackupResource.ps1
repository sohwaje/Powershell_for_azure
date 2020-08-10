################################################################################
#                                   변수 설정                                   #
################################################################################
$rgName                       = "ISCREAM"
$AzRecoveryServicesVault_name = "hiclass-backup-recovery"
$vmName                       = "Redis-Hi-Class-Service"
################################################################################
#                         백업 관련 자격증명 가져오기                            #
################################################################################
# 백업 관련 구독의 모든 자격 증명 모음
Get-AzRecoveryServicesVault
# 자격 증명 모음 컨텍스트 설정
Get-AzRecoveryServicesVault `
 -Name $AzRecoveryServicesVault_name `
 -ResourceGroupName $rgName | Set-AzRecoveryServicesVaultContext
# 자격증명 모음 ID를 가져와서 $targetVault.ID에 전달하기
$targetVault = Get-AzRecoveryServicesVault `
 -ResourceGroupName $rgName `
 -Name $AzRecoveryServicesVault_name
$targetVault.ID
# 자격 증명 모음에서 사용할 수 있는 보호 정책 확인
Get-AzRecoveryServicesBackupProtectionPolicy `
 -WorkloadType "AzureVM" `
 -VaultId $targetVault.ID
# 백업된 VM 선택
$namedContainer = Get-AzRecoveryServicesBackupContainer `
 -ContainerType "AzureVM" `
 -Status "Registered" `
 -FriendlyName $vmName `
 -VaultId $targetVault.ID
$backupitem = Get-AzRecoveryServicesBackupItem `
 -Container $namedContainer `
 -WorkloadType "AzureVM" `
 -VaultId $targetVault.ID
################################################################################
#                         백업 중지 그리고 데이터 보존                           #
################################################################################
Disable-AzRecoveryServicesBackupProtection `
 -Item $backupitem `
 -VaultId $targetVault.ID

 ################################################################################
 #                         백업 중지 그리고 데이터 삭제                           #
 ################################################################################
Disable-AzRecoveryServicesBackupProtection `
 -Item $backupitem `
 -VaultId $targetVault.ID `
 -RemoveRecoveryPoints
