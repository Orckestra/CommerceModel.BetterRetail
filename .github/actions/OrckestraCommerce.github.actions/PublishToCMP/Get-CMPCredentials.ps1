Import-Module (Join-Path $PSScriptRoot "helpers.psm1") -Force

$CMPModule = (Join-Path $PSScriptRoot "Cmp-Client.psm1")

if (Test-Path $CMPModule) {
    Write-Host "Found a cached version of the CMP-Client module. Removing it to download the latest version"
    Remove-Item -Path $CMPModule
}

$uri = "$url/download?filename=posh-cmp-client/cmp-client.psm1";
Write-Host "Downloading script $uri"
Retry -message "Downloading CMP client" -startDelayInSeconds 5 -count 5 -func {
    Invoke-WebRequest -UseBasicParsing -Uri $uri -OutFile $CMPModule
}

Import-Module $CMPModule -force

if (-not $global:OCCTOCMPCredentials) {
    if ([String]::IsNullOrWhiteSpace($username)) {
        $username = "$($env:USERDOMAIN)\$($env:UserName)"
    }

    if (-not [String]::IsNullOrWhiteSpace($password)) {
        $securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
        $global:OCCTOCMPCredentials = New-Object System.Management.Automation.PSCredential ($username, $securePassword)
    }
    else {
        $global:OCCTOCMPCredentials = Get-Credential -UserName $username -Message 'Please enter your credentials to CMP'
    }
}

try {
    Retry -message "Connecting to CMP" -startDelayInSeconds 5 -count 5 -func {
        Connect-CmpApi -Url $url -Credential $global:OCCTOCMPCredentials
    }
}
catch {
    $global:OCCTOCMPCredentials = $null
    throw
}
