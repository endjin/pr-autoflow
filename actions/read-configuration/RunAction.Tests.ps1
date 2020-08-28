$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$sutPath = Join-Path $here $sut

$repoDir = Resolve-Path (Join-Path $here '../..')

Write-Host "Here: $here"
Write-Host "Repo dir: $repoDir"

Remove-Module Endjin.GitHubActions -Force -ErrorAction SilentlyContinue
[array]$existingModule = Get-Module -ListAvailable Endjin.GitHubActions
if (!$existingModule) {
    Install-Module Endjin.GitHubActions -Force -Scope CurrentUser
} else {
    Update-Module Endjin.GitHubActions -Force -Scope CurrentUser
}
Import-Module Endjin.GitHubActions

Describe 'read-configuration RunAction UnitTests' -Tag Unit {
    Context 'Missing config file' {
        It 'should raise an error when supplied config file does not exist' {
            { & $sutPath -ConfigFile 'doesnotexist.json' | Should Throw }
        }
    }

    Context 'Valid config file' {
        Mock Set-Output { } -Verifiable -ParameterFilter { $name -eq 'configJson' }
        Mock Set-Output { } -Verifiable -ParameterFilter { $name -eq 'foo' -and $value -eq '1' }
        Mock Set-Output { } -Verifiable -ParameterFilter { $name -eq 'bar' -and $value -eq '2' }

        It 'should run successfully' {
            & $sutPath -ConfigFile (Join-Path $here 'test-config.json')

            Assert-VerifiableMock
        }
    }
}

Describe 'read-configuration RunAction Integration Tests' -Tag Integration {

    $dockerfilePath = Join-Path $here Dockerfile.local

    # Ensure we have an up-to-date image and that it builds correctly
    It 'Docker container image should build successfully' {
        docker build -t read-configuration --no-cache -f $dockerfilePath $repoDir

        $LASTEXITCODE | Should -Be 0
    }

    # Use '%--' to prevent powershell from pre-parsing the arguments we are sending to Docker
    $baseDockerCmd = "docker run --rm -v $($here):/tmp read-configuration --%"
    $baseActionParams = @(
        '-ConfigFile'
        '"tmp/test-config.json"'
    )

    It 'Docker container should run successfully' {
        $actionArgs = ($baseActionParams -join ' ')
        $dockerCmd = "$baseDockerCmd $actionArgs"
        $res = Invoke-Expression $dockerCmd

        $LASTEXITCODE | Should -Be 0
        ($res -match "::set-output").Count | Should -Be 3
    }
}
