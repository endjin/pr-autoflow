$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$sutPath = Join-Path $here $sut

Import-Module $here/module/dependabot-pr-parser.psm1 -DisableNameChecking

Describe 'RunAction Tests' {

    Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'dependency_name' }
    Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'version_from' }
    Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'version_to' }
    Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'folder' }
    
    Context 'Non-matching package' {
        Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'is_interesting_package' -and $value -eq $false }

        It 'should run successfully with no package patterns specified' {
            & $sutPath -Title 'Bump Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground'

            Assert-VerifiableMock
            Assert-MockCalled SetOutputVariable -Times 5
        }

        It 'should run successfully with a non-matching pattern specified' {
            & $sutPath -Title 'Bump Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground' -PackageNamePatterns 'Corvus.*'

            Assert-VerifiableMock
            Assert-MockCalled SetOutputVariable -Times 5
        }

        It 'should run successfully with a non-matching JSON-formatted pattern specified' {
            & $sutPath -Title 'Bump Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground' -PackageNamePatternsJsonArray '["Corvus.*"]'

            Assert-VerifiableMock
            Assert-MockCalled SetOutputVariable -Times 5
        }
    }

    Context 'Matching package' {
        Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'is_interesting_package' -and $value -eq $true }
        Mock SetOutputVariable { } -Verifiable -ParameterFilter { $name -eq 'update_type' }

        It 'should run successfully with a matching pattern specified' {
            & $sutPath -Title 'Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground' -PackageNamePatterns 'Corvus.*'

            Assert-VerifiableMock
            Assert-MockCalled SetOutputVariable -Times 6
        }

        It 'should run successfully when matching one of multiple specified patterns' {
            & $sutPath -Title 'Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground' -PackageNamePatterns @('Corvus.*', 'Menes.*')

            Assert-VerifiableMock
            Assert-MockCalled SetOutputVariable -Times 6
        }

        It 'should run successfully with a matching JSON-formatted pattern specified' {
            & $sutPath -Title 'Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground' -PackageNamePatternsJsonArray '["Corvus.*"]'

            Assert-VerifiableMock
            Assert-MockCalled SetOutputVariable -Times 6
        }

        It 'should run successfully when matching one of multiple specified JSON-formatted patterns' {
            & $sutPath -Title 'Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground' -PackageNamePatternsJsonArray '["Corvus.*","Menes.*"]'

            Assert-VerifiableMock
            Assert-MockCalled SetOutputVariable -Times 6
        }
    }
}
