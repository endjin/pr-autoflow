$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$sutPath = Join-Path $here $sut

$repoDir = Resolve-Path (Join-Path $here '../..')
$moduleDir = Resolve-Path (Join-Path $repoDir 'module')

Write-Host "Here: $here"
Write-Host "Repo dir: $repoDir"
Write-Host "Module dir: $moduleDir"

Describe 'Missing Module UnitTests (dependabot-pr-parser)' -Tag Unit {
    It 'should raise an error when the Endjin.PRAutoflow module is not loaded' {
        Remove-Module Endjin.PRAutoflow -ErrorAction SilentlyContinue
        { & $sutPath -Title 'Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground' `
                     -PackageWildCardExpressions @("Corvus.*") } | Should Throw
    }
}

Describe 'dependabot-pr-parser RunAction UnitTests' -Tag Unit {

    Import-Module $moduleDir/Endjin.PRAutoflow.psd1 -DisableNameChecking -Force

    # Mock SetOutputVariable { }
    Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'dependency_name' }
    Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'version_from' }
    Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'version_to' }
    Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'folder' }
    
    Context 'Non-matching package' {
        Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'is_interesting_package' -and $value -eq $false }
        Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'semver_increment' -and $value -eq 'major' }

        It 'should run successfully with no package patterns specified' {
            & $sutPath -Title 'Bump Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground'

            Assert-VerifiableMock
        }

        It 'should run successfully with a non-matching pattern specified' {
            & $sutPath -Title 'Bump Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground' -PackageWildCardExpressions 'Corvus.*'

            Assert-VerifiableMock
        }

        It 'should run successfully with a non-matching JSON-formatted pattern specified' {
            & $sutPath -Title 'Bump Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground' -PackageWildCardExpressions '["Corvus.*"]'

            Assert-VerifiableMock
        }
    }

    Context 'Matching package' {
        Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'is_interesting_package' -and $value -eq $true }
        Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'semver_increment' -and $value -eq 'patch' }

        It 'should run successfully with a matching pattern specified' {
            & $sutPath -Title 'Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground' -PackageWildCardExpressions 'Corvus.*'

            Assert-VerifiableMock
        }

        It 'should run successfully when matching one of multiple specified patterns' {
            & $sutPath -Title 'Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground' -PackageWildCardExpressions @('Corvus.*', 'Menes.*')

            Assert-VerifiableMock
        }

        It 'should run successfully with a matching JSON-formatted pattern specified' {
            & $sutPath -Title 'Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground' -PackageWildCardExpressions '["Corvus.*"]'

            Assert-VerifiableMock
        }

        It 'should run successfully when matching one of multiple specified JSON-formatted patterns' {
            & $sutPath -Title 'Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground' -PackageWildCardExpressions '["Corvus.*","Menes.*"]'

            Assert-VerifiableMock
        }
    }
}

Describe 'dependabot-pr-parser RunAction Integration Tests' -Tag Integration {

    $dockerfilePath = Join-Path $here Dockerfile.local

    # Ensure we have an up-to-date image and that it builds correctly
    It 'Docker container image should build successfully' {
        docker build -t dependabot-pr-parser --no-cache -f $dockerfilePath $repoDir

        $LASTEXITCODE | Should -Be 0
    }

    # Use '%--' to prevent powershell from pre-parsing the arguments we are sending to Docker
    $baseDockerCmd = "docker run --rm dependabot-pr-parser --%"
    $baseActionParams = @(
        '-Title'
        '"Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground"'
    )

    It 'Docker container should run successfully when passing only a PR title' {
        $actionArgs = ($baseActionParams -join ' ')
        $dockerCmd = "$baseDockerCmd $actionArgs"
        $res = Invoke-Expression $dockerCmd

        $LASTEXITCODE | Should -Be 0
        ($res -match "::set-output").Count | Should -Be 6
    }

    It 'Docker container should run successfully when passing a PR title and a non-matching pattern' {
        $actionArgs = (($baseActionParams + '-PackageWildcardExpressions [\"Newtonsoft.Json.*\"]') -join ' ')
        $dockerCmd = "$baseDockerCmd $actionArgs"
        $res = Invoke-Expression $dockerCmd

        $LASTEXITCODE | Should -Be 0
        ($res -match "::set-output").Count | Should -Be 6
    }

    It 'Docker container should run successfully when passing a PR title and a matching pattern' {
        $actionArgs = (($baseActionParams + '-PackageWildcardExpressions [\"Corvus.*\"]') -join ' ')
        $dockerCmd = "$baseDockerCmd $actionArgs"
        $res = Invoke-Expression $dockerCmd

        $LASTEXITCODE | Should -Be 0
        ($res -match "::set-output").Count | Should -Be 6
    }

    It 'Docker container should return non-zero if the action fails' {
        $dockerCmd = ('{0} -Title "My own PR"' -f $baseDockerCmd)
        $res = Invoke-Expression $dockerCmd

        $LASTEXITCODE | Should -Be 1
        ($res -join " ") | Should -BeLike "*Error:*"
    }
}
