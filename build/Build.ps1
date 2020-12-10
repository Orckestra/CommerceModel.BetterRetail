<# 
.SYNOPSIS
Main script to execute build and test related tasks. This script is used on both development machines and build machines.

.DESCRIPTION 
This script is only a thin wrapper around our psake script (Build.psake.ps1). Since the current 
script has parameters with 'ValidateSet', it is easier to use than the hashtable that has to
be provided to Invoke-psake. It also avoids the need to import the psake module yourself.

To print more details about progress, you can use the -Verbose common parameter.

To get up and running quickly on psake, refer to the following: https://github.com/psake/psake/wiki

.EXAMPLE

.\Build.ps1 -Docs

List available tasks defined in Build.psake.ps1:

.EXAMPLE

.\Build.ps1 All

Runs all the steps

.EXAMPLE

.\Build.ps1 -TaskList Clean,Compile -Configuration Release

Cleans and compiles everything in the 'Release' configuration.
#>

[cmdletbinding(DefaultParameterSetName = "execute")]
param(
    # The list of tasks to execute. By default, it will execute all tasks.
    [Parameter(Position = 0, ParameterSetName = 'execute', Mandatory = $true, HelpMessage = "Which tasks do you want to run? Start the script with -Docs to list the available tasks.")]
    [string[]]$TaskList,

    # The configuration to use when compiling/deploying/testing. Defaults to 'Debug'.
    [Parameter(Position = 1, ParameterSetName = 'execute')]
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration,

    # Can be used to change the verbosity used when compiling the solutions. Defaults to 'normal'.
    [Parameter(Position = 2, ParameterSetName = 'execute')]
    [ValidateSet('quiet', 'minimal', 'normal', 'detailed', 'diagnostic')]
    [string]$MsbuildVerbosity,

    # Since the script is used both on dev machine and on build machine, this parameter is used to specify
    # where it is called from. You should not have to use this parameter on your machine.
    [Parameter(Position = 3, ParameterSetName = 'execute')]
    [switch]$IsRunningOnBuildMachine,

    # Can be used to pass non standard properties to the psake script. This is usually only needed 
    # when builds are started by the VSTS agents that have to provide some credentials.
    [Parameter(Position = 4, ParameterSetName = 'execute')]
    $ExtraProperties,

    # Use this switch to list the available tasks that can be provided to 'TaskList'.
    [Parameter(ParameterSetName = 'doc')]
    [switch]$Docs
)

# Fail on first error.
$ErrorActionPreference = 'Stop'


function UpdateNugetConfigFromFeeds {
    if ($ExtraProperties -and $ExtraProperties.NugetFeeds) {
        $nugetFiles = @(
            (Join-Path $PSScriptRoot "..\nuget.config"),
            (Join-Path $PSScriptRoot "nuget.config")
        )
        
        foreach ($nugetFile in $nugetFiles) {
            $xmlContent = [xml] (Get-Content -Path $nugetFile -Raw)

            $passwordNodes = $xmlContent.SelectNodes("//add[@key='ClearTextPassword']")

            foreach ($passwordNode in $passwordNodes) {
                $passwordNode.SetAttribute("value", $ExtraProperties.NugetFeeds["Release"].password) # assume that we have the same PAT for every feed
            }

            $xmlContent.Save($nugetFile)
        }
    }
}

$originalPsModulePath = $env:PSModulePath
try {
    $env:PSModulePath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'lib\PowerShellModules;') + $env:PSModulePath
    
    if ($Configuration.Length -eq 0) {
        $Configuration = 'Debug'
    }

    if ($MsbuildVerbosity.Length -eq 0) {
        $MsbuildVerbosity = 'normal'
    }

    Import-Module psake -Verbose:$false -Force

    $psakeScript = Join-Path $PSScriptRoot 'Build.psake.ps1'

    function Get-TaskSubTree([int]$Indent, $Task, $TasksHashTable) {
        $prefix = ' ' * $Indent
        Write-Host "$prefix$($Task.Name)"
        $Task.Name
        foreach ($subTask in $Task.'Depends On') {
            Get-TaskSubTree -Indent ($Indent + 2) $TasksHashTable[$subTask] $TasksHashTable
        }
    }
   
    if ($Docs) {
        $tasks = Invoke-psake $psakeScript -structuredDocs -nologo
        $tasksHashTable = @{}
        $tasks | ForEach-Object { $tasksHashTable[$_.Name] = $_ }

        if (!$TaskList) {
            Write-Host '
The following displays the available tasks that you can provide to -TaskList. 
The hierarchy of the tasks is also displayed.
'
            $printedTasks = @()

            Get-TaskSubTree -Indent 2 -Task $tasksHashTable['all'] -TasksHashTable $tasksHashTable | % {
                $printedTasks += $_
            }

            $extraTasks = $tasks | Where-Object { $_.Name -notin $printedTasks }
            if ($extraTasks) {
                Write-Host '***********************************************************'
                Write-Host 'Extra tasks:'
                $extraTasks | % { Write-Host "  $($_.Name)" }
                Write-Host '***********************************************************'
            }
            Write-Host ''
            return
        }

        Write-Host 'The following displays the hierarchy of the tasks passed with ''-TaskList''.'

        $TaskList | ForEach-Object {
            $startupTask = $tasksHashTable[$_]

            Get-TaskSubTree -Indent 2 -Task $startupTask -TasksHashTable $tasksHashTable | Out-Null
            Write-Host ''
        }
    }
    else {
        #
        # If the user called the current script with -Verbose or -Debug, we want this option to propagate to 
        # our psake script. By default, these options don't propagate to other modules. This is why 
        # we have to do this propagation ourselves.
        #
        # See http://stackoverflow.com/questions/16406682/write-verbose-ignored-in-powershell-module for more details.
        #
        $verboseEnabled = (Write-Verbose 'x' 4>&1).Length -gt 0

        $psakeProperties = @{
            Configuration           = $Configuration; 
            IsRunningOnBuildMachine = $IsRunningOnBuildMachine; 
            MsbuildVerbosity        = $MsbuildVerbosity
        }   

        foreach ($key in $ExtraProperties.Keys) {
            $value = $ExtraProperties[$key]
            $psakeProperties.Add($key, $value)
        }

        if ($IsRunningOnBuildMachine) {
            Write-Output $psakeProperties
        }

        UpdateNugetConfigFromFeeds # workaround until we figure out how to handle PAT in a public repo

        Invoke-psake $psakeScript -properties $psakeProperties -taskLis $TaskList -nologo -Verbose:$verboseEnabled

        if ($psake.build_success -ne $true) {
            throw 'psake failed.'
        }
        
        if ($psake.number_of_test_run_errors -ne 0) {
            throw "psake ran until the end but $($psake.number_of_test_run_errors) test runs failed."
        }
    }
}
finally {
    $env:PSModulePath = $originalPsModulePath 
}
