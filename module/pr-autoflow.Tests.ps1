$here = Split-Path -Parent $MyInvocation.MyCommand.Path


Import-Module $here/pr-autoflow.psd1 -Force
function foo {
    param (
        [Parameter()]
        [JsonTransform()]
        [string[]] $list
    )
 
    return $list
}

Describe 'Module tests' {

    It 'should expose the JsonTransformAttribute class when importing the module' {
        $res = $(foo -list '["foo","bar"]')
        $res.Count | Should -Be 2
    }
}