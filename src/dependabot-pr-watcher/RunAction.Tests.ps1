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

    
    
    Context 'Non-matching package' {
    }

    Context 'Matching package' {
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
