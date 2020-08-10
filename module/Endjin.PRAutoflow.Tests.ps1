$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Remove-Module Endjin.GitHubActions -Force
[array]$existingModule = Get-Module -ListAvailable Endjin.GitHubActions
if (!$existingModule) {
    Install-Module Endjin.GitHubActions -Force -Scope CurrentUser
} else {
    Update-Module Endjin.GitHubActions -Force -Scope CurrentUser
}
Import-Module Endjin.GitHubActions

Import-Module $here/Endjin.PRAutoflow.psd1 -Force

Describe 'Packaging/publishing tests' {
    It 'should successfully create the nupkg when publishing the module' {
        {
            $tempDir = New-Item -ItemType Directory "TestDrive:\testrepo"
            try {
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