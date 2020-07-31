$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'ParsePrTitle Tests' -Tag Unit {
    
    It 'should fail when parsing a non-Dependabot PR' {
        { ParsePrTitle -Title 'My very own PR' }  | Should -Throw
    }

    Context 'Extracting PR details' {
        $res = ParsePrTitle -Title 'Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground'

        It 'should extract the correct information' {
            $res.Count | Should -Be 4
        }

        It 'should extract the dependency name' {
            $res[0] | Should -Be 'Corvus.Extensions.Newtonsoft.Json'
        }
        
        It 'should extract the current version' {
            $res[1] | Should -Be '0.9.0'
        }

        It 'should extract the new version' {
            $res[2] | Should -Be '1.0.0'
        }

        It 'should extract the folder name' {
            $res[3] | Should -Be '/Solutions/dependency-playground'
        }
    }
}