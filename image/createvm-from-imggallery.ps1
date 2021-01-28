$gallery_ResourceGroupName = "myGalleryRG"
$gallery_name      = "myGallery"
$gallery_location   = "koreacentral"
# 원본 가상 머신 이름
$sourceVM_name     = "vmsstemplate"
# 원본 가상 머신 리소스 그룹
$myResourceGroupName = "ISCREAM"


# 갤러리 가져오기
Get-AzResource -ResourceType Microsoft.Compute/galleries | Format-Table

# Mygallery 리소스 그룹에서 mygallery 라는 갤러리를 가져옵니다.
$gallery = Get-AzGallery `
   -Name $gallery_name `
   -ResourceGroupName $gallery_ResourceGroupName

# VM 가져오기
$sourceVm = Get-AzVM `
   -Name $sourceVM_name  `
   -ResourceGroupName $myResourceGroupName

### Deprovision은 고유 UUID를 삭제한다
#   sudo waagent -deprovision
###

# VM을 중지
Stop-AzVM `
  -ResourceGroupName $myResourceGroupName `
  -Name $sourceVM_name `
  -Force

# 이미지 정의 만들기 : 새로운 이미지를 만들 때 Publisher, Offer, Sku는 변경해야 한다.
# -OsState generalized, specialized
$imageDefinition = New-AzGalleryImageDefinition `
   -GalleryName $gallery_name `
   -ResourceGroupName $gallery_ResourceGroupName `
   -Location $gallery_location     `
   -Name 'vmssImagev2-Definition' `
   -OsState specialized `
   -OsType Linux `
   -Publisher 'sohwaje' `
   -Offer 'CentOS' `
   -Sku 'v7.7'

# 이미지 버전 만들기
$region1 = @{Name='koreacentral';ReplicaCount=1}
$targetRegions = @($region1)

$job = $imageVersion = New-AzGalleryImageVersion `
   -GalleryImageDefinitionName $imageDefinition.Name`
   -GalleryImageVersionName '2.0.0' `
   -GalleryName $gallery_name `
   -ResourceGroupName $gallery_ResourceGroupName `
   -Location $gallery_location `
   -TargetRegion $targetRegions  `
   -SourceImageId $sourceVm.Id.ToString() `
   -PublishingProfileEndOfLifeDate '2021-12-01' `
   -asJob

# 작업 진행률 보기
$job.State
