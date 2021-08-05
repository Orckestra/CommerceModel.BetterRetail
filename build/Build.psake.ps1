#---------------------------------------------------------------------------------------
#
# This script is used to run the same build process on dev machines and on official 
# build machines. By using this script on your dev machine, you are therefore using 
# the same steps as on the build machine.
#
# Note that the script Build.ps1 makes it easier to call Build.psake.ps1. You should
# be using Build.ps1 instead.
#
# GUIDELINES:
# -----------
#
# In order to avoid surprises, the script follows these guidelines:
#
#   - all the tasks executed on a dev machine will be executed the exact same way
#     on the build machine.
#   - some tasks may be done only on the build machine (ex: SonarQube analysis) or 
#     only on dev machines (ex: deploy environment)
#   - compiling from the build script should do the same thing as compiling from 
#     within VisualStudio.
#  
#---------------------------------------------------------------------------------------


# Fail on first error.
$ErrorActionPreference = 'Stop'


#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------
#
#                                 psake properties
#
# The following properties can be overwritten from the command line by using the 
# -properties option of Invoke-psake.
#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------

properties {
    $Configuration = 'Debug'   # Can be: Debug, Release
    $IsRunningOnBuildMachine = $false
    $MsbuildVerbosity = 'normal'  # Can be: q[uiet], m[inimal], n[ormal], d[etailed], and diag[nostic]
    $NugetVerbosity = 'quiet'   # Can be: normal, quiet, detailed
    $NugetFeeds = $null     # Will be set only when running on build machine.
    $SensitiveData = $null
    $BuildReason = $null
}



#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------
#
#                                High level targets
#
# The following targets describe the overall flow of the script. See the sub targets
# for more details.
#
#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------

Task default      -depends All # This task needs to be provided because -Docs does not return the 'default' task. I therefore introduce a dummy task.

Task All          -depends Clean,
                           Compile,
                           Publish

Task Clean        -depends CleanPackages,
                           CleanSolutions,
                           CleanArtifacts `
    -precondition { $IsRunningOnBuildMachine -eq $false }   # No need to clean on build machine since we always start from a brand new workspace.

Task Compile      -depends RestorePackages,
                           ReplaceSensitiveData,
                           InitializeAssemblyVersion,
                           InitializeDeploymentPackageManifestVersion,
                           DetectBuildStability,
                           CompileSolutions,
                           GeneratePackages

Task Publish      -depends PublishPackages,
                           PublishArtifacts

#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------
#
#                               Global initializations
#
#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------

# This function changes what psake prints when a task starts.
FormatTaskName {
    param($taskName)
    "[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss')] $taskName"
}

# Since we don't stop psake when test fails, we need a flag that will track how many 
# tests fail.
$psake.number_of_test_run_errors = 0

$WorkspaceRoot = Split-Path $psake.build_script_dir -Parent


# Download nuget packages that are required very soon in the build process for PsUtil
# (i.e. before RestorePackages is called)
$packages = Copy-Item "$WorkspaceRoot\build\packages.bootstrap.config" -Destination (Join-Path $env:TEMP 'packages.config') -Force -PassThru
Exec { & "$WorkspaceRoot\lib\nuget\nuget.exe" restore $packages.FullName -PackagesDirectory "$WorkspaceRoot\packages\NuGet" -ConfigFile "$WorkspaceRoot\nuget.config" -Verbosity quiet }
Get-ChildItem "$WorkspaceRoot\packages\NuGet" -Recurse -Include Orckestra.PsUtil.psd1 |
ForEach-Object { Import-Module $_.FullName -Global -Force -Verbose:$false } 

$ArtifactsStagingDirectory = "$WorkspaceRoot\artifacts"
$TroubleshootingArtifactsStagingDirectory = "$ArtifactsStagingDirectory\Troubleshooting"
$CentralLogsFolder = "$TroubleshootingArtifactsStagingDirectory\Logs"
$TestResultsCentralDirectory = "$TroubleshootingArtifactsStagingDirectory\Tests"
$NugetArtifactsDirectory = "$ArtifactsStagingDirectory\Nuget"
$VisualStudioVersion = '2019'
$filesWithSensitiveData = @(
    (Join-Path $WorkspaceRoot 'src\CommerceModel.BetterRetail\artifacts\OOE\BetterRetail\QueueOrderSchemaImportActivity\providers.json'),
    (Join-Path $WorkspaceRoot 'src\CommerceModel.BetterRetail\artifacts\OOE\BetterRetail\CreateUsersActivity\users.json')
)

function Create-ArtifactsFolder {
    New-FolderIfNotExists $ArtifactsStagingDirectory
    New-FolderIfNotExists $TroubleshootingArtifactsStagingDirectory
    New-FolderIfNotExists $CentralLogsFolder
    New-FolderIfNotExists $TestResultsCentralDirectory
    New-FolderIfNotExists $NugetArtifactsDirectory
}

Create-ArtifactsFolder


#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------
#
#                                     Psake tasks
#
#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------

Task CleanPackages {
    Remove-FolderIfExists -Folder (Join-Path $WorkspaceRoot 'packages')
}

Task CleanSolutions {
    Get-AllSolutions | Invoke-MsbuildClean -Configuration $Configuration -VisualStudioVersion $VisualStudioVersion
}

Task CleanArtifacts {
    Remove-FolderIfExists -Folder $ArtifactsStagingDirectory
    Create-ArtifactsFolder
}

Task RestorePackages {
    $toRestore = ("$WorkspaceRoot\Build\packages.bootstrap.config",
        "$WorkspaceRoot\Build\packages.config",
        (Get-AllSolutions))

    $toRestore | Invoke-NugetRestore -NugetVerbosity $NugetVerbosity -VisualStudioVersion $VisualStudioVersion

    #To work a bug in current 1.5.0 installer that tries to get sln from packages folders delete any sln in packages
    Get-ChildItem "$WorkspaceRoot\Packages" -Include *.sln -Recurse | Remove-Item
}

Task CompileSolutions {
    Get-AllSolutions | 
    Invoke-Msbuild -Configuration $Configuration -LogsDirectory $CentralLogsFolder -MsbuildVerbosity $MsbuildVerbosity -VisualStudioVersion $VisualStudioVersion -IsRunningOnBuildMachine:$IsRunningOnBuildMachine
}

Task GeneratePackages {  
    $version = Get-NugetPackagesVersion

    Get-ChildItem $NugetArtifactsDirectory -Include *.nupkg -Recurse | Remove-Item

    Find-CsProjsThatGenerateNugetPackage | 
    Find-NuspecInOutputFolder -Configuration $Configuration |
    Invoke-NugetPackage -Version $version -OutputDirectory $NugetArtifactsDirectory -NugetVerbosity $NugetVerbosity

    #If we are not running on build machine also publish this package to C:\Packages for local development and restore for commerce model installer
    if (-not $IsRunningOnBuildMachine) {
        $destinationFolder = "C:\Packages\"

        if (!(Test-Path -Path $destinationFolder)) {
            New-Item $destinationFolder -Type Directory
        }

        Get-ChildItem $NugetArtifactsDirectory *.nupkg | Copy-Item -Destination $destinationFolder
    }
}

Task ReplaceSensitiveData {
    $replacements = Get-SensitiveData

    foreach ($file in $filesWithSensitiveData) {
        $content = Get-Content -Path $file -Raw

        foreach ($data in $replacements.GetEnumerator()) {
            $token = "#" + $data.Name + "#"

            if ($data.Value -and $data.Value -ne "<" + $data.Name + ">") {
                # the documentation has <TOKENNAME> as a default value and we do not want to replace the token with that value
                $content = $content.Replace($token, $data.Value)
            }
        }

        $content | Set-Content -Path $file -NoNewline
    }
}

Task PreventSensitiveData  -precondition { $IsRunningOnBuildMachine } {
    foreach ($file in $filesWithSensitiveData) {
        $content = Get-Content -Path $file -Raw
        $result = $content | Select-String '.*#[^\s]+#.*' -AllMatches | Select-Object -Expand Matches | Select-Object -expand Value

        if (-not $result) {
            Write-Error "File $file did not have any replacement value. Did you commit files with sensitive data? You may need to put the replacement value back and rebase your commits to hide them."
        }
    }
}

Task UndoSensitiveData {
    $replacements = Get-SensitiveData

    foreach ($file in $filesWithSensitiveData) {
        $content = Get-Content -Path $file -Raw

        foreach ($data in $replacements.GetEnumerator()) {
            # adding quotes to the search & replace to lower the chance of a false replacement

            $token = "`"#" + $data.Name + "#`""
            $content = $content.Replace("`"" + $data.Value + "`"", $token)
        }

        $content | Set-Content -Path $file -NoNewline
    }
}

Task PublishPackages {
    # This task depends on:
    # - variable BuildStability set by DetectBuildStability

    if ($BuildReason -eq "PullRequest") {
        Write-Host "PullRequest build detected. Skipping Nuget publishing."
        return
    }

    if ($NugetFeeds) {
        if ($NugetFeeds.Contains($BuildStability.nuget)) {
            $NugetFeed = $NugetFeeds[$BuildStability.nuget].url
            $NugetUser = $NugetFeeds[$BuildStability.nuget].username
            $NugetPassword = $NugetFeeds[$BuildStability.nuget].password
    
            if ($NugetUser -and $NugetPassword -and $NugetFeed) {
                # Only publish packages in build jobs that have the nuget 
                # publishing information. 
                #
                # Note that the build definition used for the pull request
                # does not publish packages.
                Get-ChildItem $NugetArtifactsDirectory\*.nupkg | 
                Publish-NugetPackage -Feed $NugetFeed -User $NugetUser -Password $NugetPassword -NugetVerbosity $NugetVerbosity
            }
            else {
                Write-Host "Missing Nuget username, password or feed"
            }
        }
        else {
            throw "Could not find the configuration for '$($BuildStability.nuget)' in the provided NugetFeeds parameter"
        }
    }
    else {
        Write-Host "Nuget feeds was not provided. Skipping publishing of Nuget packages"
    }
}

Task PublishArtifacts {
    if (IsRunningOnVstsHostedAgent) {
        Upload-ArtifactToVsts -ArtifactName 'nuget' -ContainerFolder 'nuget' -Path "$WorkspaceRoot\Artifacts\nuget"
    }
    else {
        Write-Host "PublishArtifacts skipped on local machine..."
    }
}

Task InitializeDeploymentPackageManifestVersion -precondition { $IsRunningOnBuildMachine } {
    $sourceDirectory = (Get-Item (Join-Path $PSScriptRoot '..\src')).FullName  # Using Get-Item removes the '..' from the path.

    $version = (Get-CachedGitVersion).NuGetVersion -replace "^(\d+\.\d+\.\d+)-\d+-", '$1-'

    Write-Host "Updating Manifest.json ($($sourceDirectory.Replace($WorkspaceRoot, ''))) versions to '$($version)'."
    Get-ChildItem $sourceDirectory -Include Manifest.json -Recurse -ErrorAction SilentlyContinue `
    | ForEach-Object {
        Set-DeploymentPackageManifestVersion -filePath $_.FullName -version $version
        Write-Verbose " - $_"
    }
}

Task DetectBuildStability -precondition { $IsRunningOnBuildMachine } {
    $gitversionOutput = Get-CachedGitVersion
    Write-BuildStability -gitversionOutput $gitversionOutput
}

Task InitializeAssemblyVersion -precondition { $IsRunningOnBuildMachine } {
    $rootFolder = Get-GitWorkspaceRoot
    $globalAssemblyInfoPath = Join-Path (Get-GitWorkspaceRoot) 'src\Common\GlobalAssemblyInfo.cs'
    $projectsDirectoryPaths = @('src', 'tests')
    InitializeAssemblyInfo -RootFolder $rootFolder -GlobalAssemblyInfoPath $globalAssemblyInfoPath -ProjectsDirectoryPaths $projectsDirectoryPaths
}

function Get-SensitiveData {
    if (-not $SensitiveData) {
        # we assume that the file is in the correct format if it exists
        $sensitiveFile = Join-Path $WorkspaceRoot "build\build.sensitivedata.json"
        if (-not (Test-Path $sensitiveFile)) {
            return $null
        }
        Write-Host "Loading sensitive data from file"
        $json = Get-Content -Path $sensitiveFile | ConvertFrom-Json
        $SensitiveData = @{}
        $json.psobject.properties | ForEach-Object { $SensitiveData[$_.Name] = $_.Value }
    }

    return $SensitiveData
}

function Get-NugetPackagesVersion {
    if ($IsRunningOnBuildMachine) {
        # When a branch name starts with a number (ex: features/6038-search-admin-pcl) it generates
        # a prerelease label that starts with a number (ex: 3.9.0-6038-search-admi0001). This causes
        # the following error in nuget.exe:
        #
        #   nuget.exe : '3.9.0-6038-search-admi0001' is not a valid version string.
        #
        # This is because nuget.exe does not support SemVer 2.0. This should be in nuget 3.8. See
        # this bug for more details:
        #
        #   https://github.com/NuGet/Home/issues/1359
        #
        # To workaround this limitation, we remove the leading number in the pre-release tag.
        $version = (Get-CachedGitVersion).NuGetVersion -replace "^(\d+\.\d+\.\d+)-\d+-", '$1-'
    }
    else {
        $version = "0.0.0"
    }
    return $version
}

function Get-CachedGitVersion {
    if (-not $gitVersionOutput) {
        $gitVersionOutput = Get-GitVersion
    }

    return $gitVersionOutput
}

function Set-DeploymentPackageManifestVersion($filePath, $version) {
    try {
        $content = (Get-Content $filePath -Raw) | Out-String
        $manifest = $content | ConvertFrom-Json
        $manifest.Version = $version

        ConvertTo-Json $manifest | Set-Content $filePath
    }
    catch {
        throw "Unable to update the deployment package manifest: `
            $filePath `
            $content `
            $_"
    }
}

function IsRunningOnVstsHostedAgent {
    # The property 'IsRunningOnBuildMachine' is used to seperate the tasks that are
    # executed or skipped on the build machine. It is often helpful to use this property
    # even on dev machines to test the script as it will be done on a build machine.
    #
    # In that case (running on a dev machine with IsRunningOnBuildMachine = $true),
    # there are some things that can't be done simply because we are not on the build
    # machines that has some capabilities that are not available on a dev machine.
    # For these cases, the current method can be used to know if we are REALLY
    # running on a build machine.
    #
    # The logic to know if we are really on a build machine is to check for an
    # environment variable that is only defined on build machines.

    return Test-Path env:BUILD_ARTIFACTSTAGINGDIRECTORY
}

function Upload-ArtifactToVsts([string]$ArtifactName, [string]$ContainerFolder, [string]$Path) {
    Write-Host "Publishing '$ArtifactName' to VSTS..."
    # Artifacts are uploaded through VSTS logging commands:
    #
    #    https://github.com/Microsoft/vso-agent-tasks/blob/master/docs/authoring/commands.md
    #
    Write-Host "##vso[artifact.upload containerfolder=$ContainerFolder;artifactname=$ArtifactName;]$Path"
}

Task Test {
    $containers = Find-TestContainers -Configuration $Configuration
    Invoke-XUnit -Assemblies $containers -RunName 'Unit' -Parallelism all -IsRunningOnBuildMachine:$IsRunningOnBuildMachine -Coverage:(IsSonarEnabled)
}