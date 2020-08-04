$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Import-Module $here/Endjin.PRAutoflow.psd1 -Force
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

Describe 'Packaging/publishing tests' {
    It 'should successfully create the nupkg when publishing the module' {
        { 
            try {
                $tempDir = mkdir "TestDrive:\testrepo"
                $repoName = $tempDir.Name
                $repoPath = $tempDir.FullName
            
                Register-PSRepository -Name $repoName -SourceLocation $repoPath -PublishLocation $repoPath -InstallationPolicy 'Trusted'
                Publish-Module -Name (Join-Path $here "Endjin.PRAutoflow.psd1") -Repository $repoName -Verbose
            }
            finally {
                Unregister-PSRepository -Name $repoName -ErrorAction SilentlyContinue
            } 
        } | Should -Not -Throw
    }
}