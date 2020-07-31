$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'GetSemVerIncrement Tests' -Tag Unit {
    It 'detects a major upgrade' {
        $res = GetSemVerIncrement -FromVersion 1.0.0 -ToVersion 2.0.0
        $res | Should -BeOfType [string]
        $res | Should -Be 'major'
    }

    It 'detects a minor upgrade' {
        $res = GetSemVerIncrement -FromVersion 1.0.0 -ToVersion 1.1.0
        $res | Should -BeOfType [string]
        $res | Should -Be 'minor'
    }

    It 'detects a patch upgrade' {
        $res = GetSemVerIncrement -FromVersion 1.0.0 -ToVersion 1.0.1
        $res | Should -BeOfType [string]
        $res | Should -Be 'patch'
    }

    It 'throws an error when versions are the same' {
        { GetSemVerIncrement -FromVersion 1.1.0 -ToVersion 1.1.0 } | Should -Throw
    }
}