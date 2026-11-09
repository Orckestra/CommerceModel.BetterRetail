[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]
    $Url,

    [Parameter(Mandatory)]
    [string]
    $Username,

    [Parameter(Mandatory)]
    [string]
    $Password,

    [Parameter(Mandatory)]
    [string]
    $ClientCode,

    [Parameter(Mandatory)]
    [string]
    $PackageFolder,

    [Parameter(Mandatory)]
    [string]
    $Stability,

    [Parameter(Mandatory)]
    [string]
    $PackagesList,

    [Parameter(Mandatory)]
    [string]
    $PackagesListFilterType,

    [Parameter()]
    [string]
    $BuildNumber

)

$errorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot "helpers.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "VersionManagement.psm1") -Force

# build number should be removed, it was previously used before moving to the YAML build pipeline
# it was used in the package list to determined which package should be uploaded depending on the version (some package only exist in version X)
# syntax was something similar to: [>3.5]PackageName\..*\.nupkg (syntax may be wrong, I'm typing from memory)
# we should remove build number when doing story #61833
$BuildNumber = Convert-BuildNumberToDecimal -buildNumber $BuildNumber

& (Join-Path $PSScriptRoot Get-CMPCredentials.ps1)  # References $Username (as $username) and $Password (as $password)

function New-CmpPackage {
    param(
        [System.IO.FileInfo]$File, 
        [string]$stability
    )
    
    if ($File.Name -match '(.*)\.(\d+\.\d+\.\d+(?:-[\w-]+)?)\.nupkg') {
        $Name = $Matches[1]
        $Version = $Matches[2]
        $FilePath = $File.FullName
        $Stability = $stability
        
        [PSCustomObject]@{Name = $Name; Version = $Version; Stability = $Stability; Filename = $FilePath }
    }
    else {
        throw "Invalid package name: $($File.Name)"
    }
}

function Find-package {
    param(
        [string]$filter
    )

    switch ($PackagesListFilterType) {
        "RegEx" { 
            $packagesForUpload = Get-ChildItem $PackageFolder -recurse | Where-Object { $_.Name -match $filter } | ForEach-Object {
                Write-Host "Found file $($_.FullName)"
                New-CmpPackage -File $_ -Stability $Stability
            }
        }
        Default {
            # file pattern
            $packagesForUpload = Get-ChildItem $PackageFolder -recurse -Filter $filter | ForEach-Object {
                Write-Host "Found file $($_.FullName)"
                New-CmpPackage -File $_ -Stability $Stability
            }
        }
    } 
    
    if (-not $packagesForUpload) {
        throw "No packages found that match '$filter'!"
    }
    
    return $packagesForUpload
}


Write-Host "Starting Script..."

Write-Host "PackageFolder: $PackageFolder"
Write-Host "CMP username: $Username"
Write-Host "CMP PackagesList: $PackagesList"
Write-Host "CMP Stability: $Stability"
Write-Host "ClientCode: $ClientCode"
Write-Host "Url: $Url"    
Write-Host "PackagesListFilterType: $PackagesListFilterType"    
Write-Host "BuildNumber (major.minor): $BuildNumber"    

$packages = @()
$packagesToProcess = ($PackagesList -split '\r\n|\n|\r') | Where-Object { $_ }

ForEach ($package in $packagesToProcess) {
    Write-Host "Processing package $package"

    $versionSpecificationMatch = ($package | Select-String -Pattern "^(\[[^\]]+\])(.+)" -AllMatches).Matches
    if ($versionSpecificationMatch.Success) {
        $versionSpecification = $versionSpecificationMatch[0].Groups[1].Value
        $packagePart = $versionSpecificationMatch[0].Groups[2].Value
        Write-Host "Package contains a version specification $versionSpecification"

        if (Test-SemanticBuildNumber -buildNumber $BuildNumber -versionText $versionSpecification) {
            Write-Host "Looking for package $packagePart"
            $packages += Find-Package $packagePart        
        }
        else {
            Write-Host "Build number $BuildNumber does not fulfill the requirements $versionSpecification"
        }
    }
    else {
        Write-Host "Looking for package $package"
        $packages += Find-Package $package        
    }
}

Write-Host "Detected $($packages.Length) package(s) to publish"
$packages | ConvertTo-Json -Depth 10 | Write-Host

if ($ClientCode -eq 'orc') {
    $client = [PSCustomObject]@{
        Code       = 'orc';
        DomainName = '[UNDEFINED]';
        Location   = '[UNDEFINED]';
        Name       = '[UNDEFINED]'
    }
}
else {
    $client = Get-CmpClient -ClientCode $ClientCode
}    

$packages | ForEach-Object {
    $package = $_
    
    Retry -message "Publishing CMP package $($package.Name)" -startDelayInSeconds 5 -count 5 -func {
        $package | Push-CmpPackage -Client $client | Out-Null
    }
}
