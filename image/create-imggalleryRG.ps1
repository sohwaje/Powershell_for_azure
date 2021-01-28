# 이미지 갤러리 만들기
# myGalleryRG 리소스 그룹에 myGallery 라는 갤러리를 만듭니다.
$resourceGroup = New-AzResourceGroup `
   -Name 'myGalleryRG' `
   -Location 'koreacentral'
$gallery = New-AzGallery `
   -GalleryName 'myGallery' `
   -ResourceGroupName $resourceGroup.ResourceGroupName `
   -Location $resourceGroup.Location `
   -Description 'Shared Image Gallery for my organization'
