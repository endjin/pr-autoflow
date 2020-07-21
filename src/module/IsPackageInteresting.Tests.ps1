$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'IsPackageInteresting Tests' {

    It 'should return false when no patterns are specified' {
        $res = IsPackageInteresting -PackageName 'MyPackage' -PackageNamePatterns @()
        $res | Should -BeOfType [boolean]
        $res | Should -Be $false
    }

    It 'should match when passed a single pattern' {
        $res = IsPackageInteresting -PackageName 'MyPackage.Something' -PackageNamePatterns 'MyPackage.*'
        $res | Should -BeOfType [boolean]
        $res | Should -Be $true
    }

    It 'should match when passed multiple patterns' {
        $res = IsPackageInteresting -PackageName 'MyPackage.Something' -PackageNamePatterns @('Acme*','MyPackage.*')
        $res | Should -BeOfType [boolean]
        $res | Should -Be $true
    }
}