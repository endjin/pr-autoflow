[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $moduleRepoUrl = 'https://github.com/endjin/dependabot-pr-parser-powershell',

    [Parameter()]
    [string]
    $moduleBranch = 'master',

    [Parameter()]
    [switch]
    $localMode
)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$sutPath = Join-Path $here $sut

$savedPath = $PWD
$repoBase = Split-Path -Parent (Split-Path -Parent $here)

if ($localMode) {
    Write-Verbose "Running in 'localMode'"
    $dockerContextPath = (Resolve-Path "$here/../..").Path
    $dockerFile = 'Dockerfile.local'
    $modulePath = Join-Path $dockerContextPath 'module'
}
else {
    $dockerContextPath = $here
    $dockerFile = 'Dockerfile'
    $repoDir = Join-Path $repoBase '_module'
    $modulePath = Join-Path $repoDir 'src'

    Remove-Item -Force -Recurse $repoDir -ErrorAction SilentlyContinue

    Push-Location $repoBase
    git clone $moduleRepoUrl _module
    Push-Location $repoBase/_module
    git checkout $moduleBranch
    Push-Location $savedPath
}
Write-Verbose "modulePath: $modulePath"
Write-Verbose "dockerContextPath: $dockerContextPath"


Describe 'Missing Module UnitTests' -Tag Unit {
    It 'should raise an error when the dependabot-pr-parser module is not loaded' {
        Remove-Module dependabot-pr-parser -ErrorAction SilentlyContinue
        { & $sutPath -Titles @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground') `
                     -PackageWildCardExpressions @("Corvus.*") } | Should Throw
    }
}
Describe 'dependabot-pr-watcher RunAction UnitTests' -Tag Unit {

    # The script being tested now requires the module to be loaded
    Import-Module $modulePath/dependabot-pr-parser.psd1 -DisableNameChecking -Force

    Context 'Outstanding Dependabot PRs' {
        Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'is_complete' -and $value -eq $false }

        It 'reports as incomplete with matching packages' -TestCases @(
            @{ titles = @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground'); packageWildcardExpressions = @("Corvus.*", "Endjin.*") }
            @{ titles = @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.10.0 in /Solutions/dependency-playground'); packageWildcardExpressions = @("Corvus.*", "Endjin.*") }
        ) {
            param (
                [string[]] $titles,
                [string[]] $packageWildcardExpressions
            )

            & $sutPath `
                -Titles $titles `
                -PackageWildCardExpressions $packageWildcardExpressions

            Assert-VerifiableMock
        }
    }

    Context 'No PRs (JSON handling)' {
        It 'runs successfully when a null list of PRs is passed' {
            & $sutPath `
                -Titles $null -PackageWildCardExpressions '["Corvus.*", "Endjin.*"]'
        }
        
        It 'runs successfully when an empty list of PRs is passed' {
            & $sutPath `
                -Titles "[]" -PackageWildCardExpressions '["Corvus.*", "Endjin.*"]'
        }
    }

    Context 'Outstanding Dependabot PRs (JSON handling)' {
        Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'is_complete' -and $value -eq $false }

        It 'reports as incomplete with matching packages' -TestCases @(
            @{ titles = '["Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground"]'; packageWildcardExpressions = '["Corvus.*", "Endjin.*"]' }
            @{ titles = '["Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.10.0 in /Solutions/dependency-playground"]'; packageWildcardExpressions = '["Corvus.*", "Endjin.*"]' }
        ) {
            param (
                [string] $titles,
                [string] $packageWildcardExpressions
            )

            & $sutPath `
                -Titles $titles `
                -PackageWildCardExpressions $packageWildcardExpressions

            Assert-VerifiableMock
        }
    }

    Context 'No outstanding Dependabot PRs' {
        Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'is_complete' -and $value -eq $true }

        It 'reports as complete with no matching packages' -TestCases @(
            @{ titles = @('Bump Newtonsoft.Json from 0.9.0 to 0.10.0 in /Solutions/dependency-playground'); packageWildcardExpressions = @("Corvus.*", "Endjin.*") }
            @{ titles = @('Bump Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground'); packageWildcardExpressions = @("Corvus.*", "Endjin.*") }
        ) {
            param (
                [string[]] $titles,
                [string[]] $packageWildcardExpressions
            )

            & $sutPath `
                -Titles $titles `
                -PackageWildCardExpressions $packageWildcardExpressions

            Assert-VerifiableMock
        }

        It 'reports as complete with matching packages with major increment' -TestCases @(
            @{ titles = @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground'); packageWildcardExpressions = @("Corvus.*", "Endjin.*") }
        ) {
            param (
                [string[]] $titles,
                [string[]] $packageWildcardExpressions
            )

            & $sutPath `
                -Titles $titles `
                -PackageWildCardExpressions $packageWildcardExpressions

            Assert-VerifiableMock
        }
    }
}

Describe 'dependabot-pr-watcher RunAction Integration Tests' -Tag Integration {

    # Ensure we have an up-to-date image and that it builds correctly
    It 'Docker container image should build successfully' {
        Push-Location $here
        docker build -t dependabot-pr-watcher --no-cache --build-arg repoUrl=$moduleRepoUrl --build-arg branch=$moduleBranch -f $dockerFile $dockerContextPath
        Pop-Location

        $LASTEXITCODE | Should -Be 0
    }

    # Use '%--' to prevent powershell from pre-parsing the arguments we are sending to Docker
    $baseDockerCmd = "docker run -i --rm dependabot-pr-watcher --%"
    $baseActionParams = @(
        '-Titles'
        '"[\"Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground\"]"'
        '-PackageWildCardExpressions'
        '"[\"Corvus.*\", \"Endjin.*\"]"'
    )

    It 'Docker container should run successfully when passing PR titles and a matching pattern' {
        $actionArgs = $baseActionParams
        $dockerCmd = "$baseDockerCmd $actionArgs"
        Write-Verbose "dockerCmd: $dockerCmd"
        $res = Invoke-Expression $dockerCmd

        $LASTEXITCODE | Should -Be 0
        Write-Host $res
        ($res -match "::set-output name=is_complete::False").Count | Should -Be 1
    }
}
