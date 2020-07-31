$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'JsonTransformAttribute Tests' {
    It 'should convert a stringified JSON array to an array' {
        $a = new-object JsonTransformAttribute
        $res = $a.Transform($null, '["foo","bar"]')

        Should -HaveType [array] -ActualValue $res
        $res.Count | Should -Be 2
    }

    It 'should convert an empty stringified JSON array to null' {
        $a = new-object JsonTransformAttribute
        $res = $a.Transform($null, '[]')

        $res | Should -Be $null
    }

    It 'should convert a stringified JSON object to an object' {
        $a = new-object JsonTransformAttribute
        $res = $a.Transform($null, '{"foo": "bar"}')

        Should -HaveType [PSCustomObject] -ActualValue $res
        $res.foo | Should -Be 'bar'
    }

    It 'should convert an empty stringified JSON object to an empty object' {
        $a = new-object JsonTransformAttribute
        $res = $a.Transform($null, '{}')

        Should -HaveType [PSCustomObject] -ActualValue $res
        ($res | Get-Member).Count | Should -Be 4
    }
}