#Requires -Version 7
<#
.SYNOPSIS
    Runs a .NET flavoured build process.
.DESCRIPTION
    This script was scaffolded using a template from the Endjin.RecommendedPractices.Build PowerShell module.
    It uses the InvokeBuild module to orchestrate an opinonated software build process for .NET solutions.
.EXAMPLE
    PS C:\> ./build.ps1
    Downloads any missing module dependencies (Endjin.RecommendedPractices.Build & InvokeBuild) and executes
    the build process.
.PARAMETER Tasks
    Optionally override the default task executed as the entry-point of the build.
.PARAMETER ContainerRegistryType
    The type of container registry to use when publishing any images (supported values: acr,docker,ghcr)
.PARAMETER ContainerRegistryFqdn
    The fully-qualified domain name for the target container registry
.PARAMETER SourcesDir
    The path where the source code to be built is located, defaults to the current working directory.
.PARAMETER LogLevel
    The logging verbosity.
.PARAMETER BuildModulePath
    The path to import the Endjin.RecommendedPractices.Build module from. This is useful when
    testing pre-release versions of the Endjin.RecommendedPractices.Build that are not yet
    available in the PowerShell Gallery.
.PARAMETER BuildModuleVersion
    The version of the Endjin.RecommendedPractices.Build module to import. This is useful when
    testing pre-release versions of the Endjin.RecommendedPractices.Build that are not yet
    available in the PowerShell Gallery.
.PARAMETER InvokeBuildModuleVersion
    The version of the InvokeBuild module to be used.
#>
[CmdletBinding()]
param (
    [Parameter(Position=0)]
    [string[]] $Tasks = @("."),

    [Parameter()]
    [ValidateSet("", "docker", "acr", "ghcr")]
    [string] $ContainerRegistryType = "docker",

    [Parameter()]
    [string] $ContainerRegistryFqdn = "",

    [Parameter()]
    [string] $SourcesDir = $PWD,

    [Parameter()]
    [ValidateSet("minimal","normal","detailed")]
    [string] $LogLevel = "minimal",

    [Parameter()]
    [string] $BuildModulePath,

    [Parameter()]
    [version] $BuildModuleVersion = "1.3.10",

    [Parameter()]
    [version] $InvokeBuildModuleVersion = "5.10.1"
)

$ErrorActionPreference = $ErrorActionPreference ? $ErrorActionPreference : 'Stop'
$InformationPreference = 'Continue'

$here = Split-Path -Parent $PSCommandPath

#region InvokeBuild setup
if (!(Get-Module -ListAvailable InvokeBuild)) {
    Install-Module InvokeBuild -RequiredVersion $InvokeBuildModuleVersion -Scope CurrentUser -Force -Repository PSGallery
}
Import-Module InvokeBuild
# This handles calling the build engine when this file is run like a normal PowerShell script
# (i.e. avoids the need to have another script to setup the InvokeBuild environment and issue the 'Invoke-Build' command )
if ($MyInvocation.ScriptName -notlike '*Invoke-Build.ps1') {
    try {
        Invoke-Build $Tasks $MyInvocation.MyCommand.Path @PSBoundParameters
    }
    catch {
        $_.ScriptStackTrace
        throw
    }
    return
}
#endregion

#region Import shared tasks and initialise build framework
if (!($BuildModulePath)) {
    if (!(Get-Module -ListAvailable Endjin.RecommendedPractices.Build | ? { $_.Version -eq $BuildModuleVersion })) {
        Write-Information "Installing 'Endjin.RecommendedPractices.Build' module..."
        Install-Module Endjin.RecommendedPractices.Build -RequiredVersion $BuildModuleVersion -Scope CurrentUser -Force -Repository PSGallery
    }
    $BuildModulePath = "Endjin.RecommendedPractices.Build"
}
else {
    Write-Information "BuildModulePath: $BuildModulePath"
}
Import-Module $BuildModulePath -RequiredVersion $BuildModuleVersion -Force

# Load the build process & tasks
. Endjin.RecommendedPractices.Build.tasks
#endregion


#
# Build process control options
#
$SkipInit = $false
$SkipVersion = $false
$SkipBuild = $false
$CleanBuild = $false
$SkipTest = $false
$SkipTestReport = $false
$SkipAnalysis = $true
$SkipPackage = $false
$SkipPublish = $false


#
# Build process configuration
#
$ContainersToBuild = @(
    @{
        Dockerfile = "$here/actions/dependabot-pr-parser/Dockerfile"
        ImageName = "dependabot-pr-parser"
        ContextDir = "$here/actions/dependabot-pr-parser"
        Arguments = @{AllowPreRelease=$false}      # this will be dynamically updated before the image is built
    }
    @{
        Dockerfile = "$here/actions/dependabot-pr-watcher/Dockerfile"
        ImageName = "dependabot-pr-watcher"
        ContextDir = "$here/actions/dependabot-pr-watcher"
        Arguments = @{AllowPreRelease=$false}      # this will be dynamically updated before the image is built
    }
    @{
        Dockerfile = "$here/actions/read-configuration/Dockerfile"
        ImageName = "read-configuration"
        ContextDir = "$here/actions/read-configuration"
        Arguments = @{}
    }
)
$ContainerRegistryType = "docker"       # supported values: docker, acr, ghcr
$UseAcrTasks = $false                   # when true, images will be build & published using ACR Tasks
$ContainerRegistryPublishPrefix = ""    # optional additional tag details to prepend to image name when publishing to a container registry
$ContainerImageVersionOverride = ""     # override the GitVersion-generated SemVer used for tagging container images

# The above container images do not need to be published, as GHA builds them from source
$SkipPublishContainerImages = $true

$PesterTestsDir = "$here/module"
$PowerShellModulesToPublish = @(
    @{
        ModulePath = "$here/module/Endjin.PRAutoflow.psd1"
        FunctionsToExport = @("*")
        CmdletsToExport = @()
        AliasesToExport = @()
    }
)


# Synopsis: Build, Test and Package
task . FullBuild


# build extensibility tasks
task RunFirst {}
task PreInit {}
task PostInit {}
task PreVersion {}
task PostVersion {
    # Update the ContainersToBuild variables to control which module version gets installed
    for ($i=0; $i -lt $ContainersToBuild.Count; $i++) {
        if ($script:ContainersToBuild[$i].Arguments.ContainsKey("AllowPreRelease")) {
            $script:ContainersToBuild[$i].Arguments.AllowPreRelease = ![string]::IsNullOrEmpty($script:GitVersion.PreReleaseTag)
        }
    }
    Write-Build White "Updated Dockerfile arguments with current version details:"
    $ContainersToBuild | ConvertTo-Json | Write-Host
}
task PreBuild {}
task PostBuild {}
task PreTest {}
task PostTest {}
task PreTestReport {}
task PostTestReport {}
task PreAnalysis {}
task PostAnalysis {}
task PrePackage {}
task PostPackage {}
task PrePublish {}
task PostPublish {}
task RunLast {}

