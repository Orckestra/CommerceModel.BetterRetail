#=======================================
if (!$global:ctx) { throw '$global:ctx not initialized' }
#=======================================

$environment = $global:ctx.Environment
$database = $global:ctx.Database

$DatabaseConnection = Get-OvertureDatabaseDeploymentConfiguration `
							-environment $environment `
                            -DatabaseName $database

#Enable BetterRetail supported languages to allow template imports to bring in all supported languages                            
$query = ''
switch ($database) {
    "Product" {
        $query = @"
            UPDATE [dbo].[CATALOG]
            SET SupportedCulture = '<cultures><culture>en-CA</culture><culture>en-US</culture><culture>fr-CA</culture></cultures>'
            WHERE CatalogName = 'Global'
"@
    }     
    "Foundation" {
        $query = @"
            UPDATE [dbo].[CULTURE]
            SET IsSupported = 1
            WHERE CultureIso IN ('en-CA', 'en-US', 'fr-CA')
"@
    }     
}

if($query -ne '') {
    $engineEdition = $DatabaseConnection | Invoke-SqlQuery ScalarQuery -Query $query
}