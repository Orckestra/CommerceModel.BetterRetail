$errorActionPreference = 'Stop'

$numberPattern = "(\d+(?:\.\d+)?)"

$versionRangeX_To_Y_Inclusive = "\[$numberPattern-$numberPattern\]"
$versionRangeLessThanX = "\[\<$numberPattern\]"
$versionRangeLessThanOrEqualX = "\[\<=$numberPattern\]"
$versionRangeGreaterThanX = "\[\>$numberPattern\]"
$versionRangeGreaterThanOrEqualX = "\[\>=$numberPattern\]"



function IsVersionInRange([decimal]$buildNumber, [string]$versionText) {
    $matches = ($versionText | Select-String -Pattern $versionRangeX_To_Y_Inclusive -AllMatches).Matches
    $from = $matches[0].Groups[1].Value
    $to = $matches[0].Groups[2].Value

    return ($buildNumber -ge $from -and $buildNumber -le $to)
}

function IsVersionLessThan([decimal]$buildNumber, [string]$versionText) {
    $matches = ($versionText | Select-String -Pattern $versionRangeLessThanX -AllMatches).Matches
    $v = $matches[0].Groups[1].Value
    return ($buildNumber -lt $v)
}

function IsVersionLessThanOrEqual([decimal]$buildNumber, [string]$versionText) {
    $matches = ($versionText | Select-String -Pattern $versionRangeLessThanOrEqualX -AllMatches).Matches
    $v = $matches[0].Groups[1].Value
    return ($buildNumber -le $v)
}

function IsVersionGreaterThan([decimal]$buildNumber, [string]$versionText) {
    $matches = ($versionText | Select-String -Pattern $versionRangeGreaterThanX -AllMatches).Matches
    $v = $matches[0].Groups[1].Value
    return ($buildNumber -gt $v)
}

function IsVersionGreaterThanOrEqual([decimal]$buildNumber, [string]$versionText) {
    $matches = ($versionText | Select-String -Pattern $versionRangeGreaterThanOrEqualX -AllMatches).Matches
    $v = $matches[0].Groups[1].Value
    return ($buildNumber -ge $v)
}

function Test-SemanticBuildNumber([decimal]$buildNumber, [string]$versionText) {
    if ($versionText -match $versionRangeX_To_Y_Inclusive) {
        return (IsVersionInRange -buildNumber $buildNumber -versionText $versionText)
    }
    if ($versionText -match $versionRangeLessThanX) {
        return (IsVersionLessThan -buildNumber $buildNumber -versionText $versionText)
    }
    if ($versionText -match $versionRangeLessThanOrEqualX) {
        return (IsVersionLessThanOrEqual -buildNumber $buildNumber -versionText $versionText)
    }
    if ($versionText -match $versionRangeGreaterThanX) {
        return (IsVersionGreaterThan -buildNumber $buildNumber -versionText $versionText)
    }
    if ($versionText -match $versionRangeGreaterThanOrEqualX) {
        return (IsVersionGreaterThanOrEqual -buildNumber $buildNumber -versionText $versionText)
    }

    return false
}

function Convert-BuildNumberToDecimal([string] $buildNumber) {
    Write-Host "Parsing build number $buildNumber"
    
    $parsedVersion = 0
    $pattern = "(\d+\.\d+)"
    $matches = ($buildNumber | Select-String -Pattern $pattern -AllMatches).Matches
    if ($matches.Success) {
        $parsedVersion = [decimal] $matches[0].Value
        Write-Host "Succesfully parsed build number: $parsedVersion"

        return $parsedVersion
    }
    else {
        throw "Could not parse build number"
    }        
}


<#
"[3-3.5]" -match $versionRangeX_To_Y_Inclusive
"[<3.5]" -match $versionRangeLessThanX
"[<=3.5]" -match $versionRangeLessThanOrEqualX
"[>3]" -match $versionRangeGreaterThanX
"[>=5]" -match $versionRangeGreaterThanOrEqualX
#>

#Write-Host (IsVersionInRange -buildNumber 3.4 -versionText "[3-3.3]")
#Write-Host (IsVersionLessThan -buildNumber 3.4 -versionText "[<4]")
#Write-Host (IsVersionLessThanOrEqual -buildNumber 3.4 -versionText "[<=3.4]")
#Write-Host (IsVersionGreaterThan -buildNumber 3.4 -versionText "[>3.3]")
#Write-Host (IsVersionGreaterThanOrEqual -buildNumber 3.4 -versionText "[>=3.3]")


Export-ModuleMember -Function Test-SemanticBuildNumber
Export-ModuleMember -Function Convert-BuildNumberToDecimal
