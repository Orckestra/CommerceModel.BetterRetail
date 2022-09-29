#=======================================
if (!$global:ctx) { throw '$global:ctx not initialized' }
#=======================================
$storageAccountName     = Get-Param "Azure-StorageAccountName"
$storageAccountKey = Get-Param "Azure-StorageAccountKey"
$containerPrefix = Get-Param "Azure_BlobContainerSharedPrefix"
#=======================================
# Initialize Script Execution Context
$currentScriptPath = Split-Path $MyInvocation.MyCommand.Path
$rootPath = (get-item $currentScriptPath).parent.FullName
#=======================================
# BOPIS instore configurations
$bopisArtifactsPath = Join-Path $rootPath "artifacts/BlobStorage/bopisfulfillmentprovider"
$bopisContainerName = $containerPrefix + 'bopisfulfillmentprovider'  
#=======================================
# Ship From Store configurations
$shipFromStoreArtifactsPath = Join-Path $rootPath "artifacts/BlobStorage/shipfromstorefulfillmentprovider"
$shipFromStoreContainerName = $containerPrefix + 'shipfromstorefulfillmentprovider'  

Publish-ComponentArtifacts
Invoke-ComponentSolrConfigTransformation
Copy-ToBlob -BlobContainerName $bopisContainerName -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey -SourcePath $bopisArtifactsPath
Copy-ToBlob -BlobContainerName $shipFromStoreContainerName -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey -SourcePath $shipFromStoreArtifactsPath
