$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'IsPackageInteresting Tests' -Tag Unit {

    It 'should return false when no patterns are specified' {
        $res = IsPackageInteresting -PackageName 'MyPackage' -PackageWildcardExpressions @()
        $res | Should -BeOfType [boolean]
        $res | Should -Be $false
    }

    It 'should match when passed a single pattern' {
        $res = IsPackageInteresting -PackageName 'MyPackage.Something' -PackageWildcardExpressions 'MyPackage.*'
        $res | Should -BeOfType [boolean]
        $res | Should -Be $true
    }

    It 'should match when passed multiple patterns' {
        $res = IsPackageInteresting -PackageName 'MyPackage.Something' -PackageWildcardExpressions @('Acme*','MyPackage.*')
        $res | Should -BeOfType [boolean]
        $res | Should -Be $true
    }
}