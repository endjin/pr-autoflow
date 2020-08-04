$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$sutPath = Join-Path $here $sut

$repoDir = Resolve-Path (Join-Path $here '../..')
$moduleDir = Resolve-Path (Join-Path $repoDir 'module')

Write-Host "Here: $here"
Write-Host "Repo dir: $repoDir"
Write-Host "Module dir: $moduleDir"

Describe 'Missing Module UnitTests' -Tag Unit {
    It 'should raise an error when the pr-autoflow module is not loaded' {
        Remove-Module pr-autoflow -ErrorAction SilentlyContinue
        { & $sutPath -Titles @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground') `
                     -PackageWildCardExpressions @("Corvus.*") } | Should Throw
    }
}
Describe 'dependabot-pr-watcher RunAction UnitTests' -Tag Unit {

    # The script being tested now requires the module to be loaded
    Import-Module $moduleDir/Endjin.PRAutoflow.psd1 -DisableNameChecking -Force

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

    $dockerfilePath = Join-Path $here Dockerfile_test

    # Ensure we have an up-to-date image and that it builds correctly
    It 'Docker container image should build successfully' {
        docker build -t dependabot-pr-watcher --no-cache -f $dockerfilePath $repoDir

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
        $res = Invoke-Expression $dockerCmd

        $LASTEXITCODE | Should -Be 0
        Write-Host $res
        ($res -match "::set-output name=is_complete::False").Count | Should -Be 1
    }
}
