$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$sutPath = Join-Path $here $sut

# Import-Module $here/module/dependabot-pr-parser.psm1 -DisableNameChecking

Describe 'RunAction Tests' {

    # Mock -ModuleName dependabot-pr-parser SetOutputVariable { throw } -Verifiable

    It 'should run successfully with no package patterns specified' {
        & $sutPath -Title 'Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground'

        # Assert-MockCalled -ModuleName dependabot-pr-parser SetOutputVariable -Times 5
    }
}
