$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$sutPath = Join-Path $here $sut

$savedPath = $PWD
$moduleBase = Split-Path -Parent (Split-Path -Parent $here)
$modulePath = Join-Path $moduleBase '_module/src'
Push-Location $moduleBase
git clone https://github.com/endjin/dependabot-pr-parser-powershell _module
Push-Location $moduleBase/_module
git checkout master
Push-Location $savedPath

Import-Module $modulePath/dependabot-pr-parser.psm1 -DisableNameChecking -Force

Describe 'RunAction UnitTests' -Tag Unit {

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

Describe 'RunAction Integration Tests' -Tag Integration {

    # Ensure we have an up-to-date image and that it builds correctly
    It 'Docker container image should build successfully' {
        docker build -t dependabot-pr-parser $here

        $LASTEXITCODE | Should -Be 0
    }

    # Use '%--' to prevent powershell from pre-parsing the arguments we are sending to Docker
    $baseDockerCmd = "docker run -i --rm dependabot-pr-parser --%"
    $baseActionParams = @(
        '-Title'
        '"Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground"'
    )

    # TODO: container tests

}
