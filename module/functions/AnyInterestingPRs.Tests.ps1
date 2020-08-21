$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

. "$here\ParsePrTitle.ps1"
. "$here\IsPackageInteresting.ps1"
. "$here\GetSemVerIncrement.ps1"

Describe 'AnyInterestingPRs Tests' -Tag Unit {

    Context 'No PRs' {
        It 'should run without error when no PRs are specified (empty array)' {
            $res = AnyInterestingPRs -Titles @() -MaxSemVerIncrement 'minor' -PackageWildcardExpressions @()
        }

        It 'should run without error when no PRs are specified (null array)' {
            $res = AnyInterestingPRs -Titles $null -MaxSemVerIncrement 'minor' -PackageWildcardExpressions @()
        }
    }
    Context 'Single PR' {
        It 'should return false when no patterns are specified' {
            $res = AnyInterestingPRs -Titles @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground') `
                                                    -MaxSemVerIncrement 'minor' `
                                                    -PackageWildcardExpressions @()
            $res | Should -BeOfType [boolean]
            $res | Should -Be $false
        }

        It 'should return false when matching patterns are specified with a SemVer increment more than MaxSemVerIncrement' {
            $res = AnyInterestingPRs -Titles @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground') `
                                                    -MaxSemVerIncrement 'minor' `
                                                    -PackageWildcardExpressions @('Corvus.*')
            $res | Should -BeOfType [boolean]
            $res | Should -Be $false
        }

        It 'should return false when matching patterns are specified but no PR matches the pattern' {
            $res = AnyInterestingPRs -Titles @('Bump Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground') `
                                                    -MaxSemVerIncrement 'minor' `
                                                    -PackageWildcardExpressions @('Corvus.*')
            $res | Should -BeOfType [boolean]
            $res | Should -Be $false
        }

        It 'should return true when matching patterns are specified with a SemVer increment less than MaxSemVerIncrement (<maxSemVerIncrement>)' -TestCases @(
            @{ titles = @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.10.0 in /Solutions/dependency-playground'); maxSemVerIncrement = 'major'; packageWildcardExpressions = @('Corvus.*'); }
            @{ titles = @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground'); maxSemVerIncrement = 'minor'; packageWildcardExpressions = @('Corvus.*'); }
        ) {
            param (
                [string[]] $titles,
                [string] $maxSemVerIncrement,
                [string[]] $packageWildcardExpressions
            )

            $res = AnyInterestingPRs `
                    -Titles $titles `
                    -MaxSemVerIncrement $maxSemVerIncrement `
                    -PackageWildcardExpressions $packageWildcardExpressions
            $res | Should -BeOfType [boolean]
            $res | Should -Be $true
        }

        It 'should return true when matching patterns are specified with a SemVer increment equal to MaxSemVerIncrement (<maxSemVerIncrement>)' -TestCases @(
            @{ titles = @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground'); maxSemVerIncrement = 'major'; packageWildcardExpressions = @('Corvus.*'); }
            @{ titles = @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.10.0 in /Solutions/dependency-playground'); maxSemVerIncrement = 'minor'; packageWildcardExpressions = @('Corvus.*'); }
            @{ titles = @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground'); maxSemVerIncrement = 'patch'; packageWildcardExpressions = @('Corvus.*'); }
        ) {
            param (
                [string[]] $titles,
                [string] $maxSemVerIncrement,
                [string[]] $packageWildcardExpressions
            )

            $res = AnyInterestingPRs `
                    -Titles $titles `
                    -MaxSemVerIncrement $maxSemVerIncrement `
                    -PackageWildcardExpressions $packageWildcardExpressions
            $res | Should -BeOfType [boolean]
            $res | Should -Be $true
        }
    }

    Context 'Multiple PRs' {
        It 'should return false when no patterns are specified' {
            $res = AnyInterestingPRs -Titles @(
                'Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground',
                'Bump Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground') `
                                                    -MaxSemVerIncrement 'minor' `
                                                    -PackageWildcardExpressions @()
            $res | Should -BeOfType [boolean]
            $res | Should -Be $false
        }

        It 'should return false when matching patterns are specified with a SemVer increment more than MaxSemVerIncrement' {
            $res = AnyInterestingPRs -Titles  @(
                'Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground',
                'Bump Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground') `
                                                    -MaxSemVerIncrement 'minor' `
                                                    -PackageWildcardExpressions @('Corvus.*')
            $res | Should -BeOfType [boolean]
            $res | Should -Be $false
        }

        It 'should return false when matching patterns are specified but no PR matches the pattern' {
            $res = AnyInterestingPRs -Titles @(
                'Bump Foo.Bar from 0.9.0 to 0.9.1 in /Solutions/dependency-playground',
                'Bump Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground') `
                                                    -MaxSemVerIncrement 'minor' `
                                                    -PackageWildcardExpressions @('Corvus.*')
            $res | Should -BeOfType [boolean]
            $res | Should -Be $false
        }

        It 'should return true when matching patterns are specified with a SemVer increment less than MaxSemVerIncrement (<maxSemVerIncrement>)' -TestCases @(
            @{ titles = @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.10.0 in /Solutions/dependency-playground', 'Bump Newtonsoft.Json from 0.9.0 to 0.10.0 in /Solutions/dependency-playground'); maxSemVerIncrement = 'major'; packageWildcardExpressions = @('Corvus.*'); }
            @{ titles = @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground', 'Bump Newtonsoft.Json from 0.9.0 to 0.10.0 in /Solutions/dependency-playground'); maxSemVerIncrement = 'minor'; packageWildcardExpressions = @('Corvus.*'); }
        ) {
            param (
                [string[]] $titles,
                [string] $maxSemVerIncrement,
                [string[]] $packageWildcardExpressions
            )

            $res = AnyInterestingPRs `
                    -Titles $titles `
                    -MaxSemVerIncrement $maxSemVerIncrement `
                    -PackageWildcardExpressions $packageWildcardExpressions
            $res | Should -BeOfType [boolean]
            $res | Should -Be $true
        }

        It 'should return true when matching patterns are specified with a SemVer increment equal to MaxSemVerIncrement (<maxSemVerIncrement>)' -TestCases @(
            @{ titles = @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground', 'Bump Newtonsoft.Json from 0.9.0 to 0.10.0 in /Solutions/dependency-playground'); maxSemVerIncrement = 'major'; packageWildcardExpressions = @('Corvus.*'); }
            @{ titles = @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.10.0 in /Solutions/dependency-playground', 'Bump Newtonsoft.Json from 0.9.0 to 0.10.0 in /Solutions/dependency-playground'); maxSemVerIncrement = 'minor'; packageWildcardExpressions = @('Corvus.*'); }
            @{ titles = @('Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 0.9.1 in /Solutions/dependency-playground', 'Bump Newtonsoft.Json from 0.9.0 to 0.10.0 in /Solutions/dependency-playground'); maxSemVerIncrement = 'patch'; packageWildcardExpressions = @('Corvus.*'); }
        ) {
            param (
                [string[]] $titles,
                [string] $maxSemVerIncrement,
                [string[]] $packageWildcardExpressions
            )

            $res = AnyInterestingPRs `
                    -Titles $titles `
                    -MaxSemVerIncrement $maxSemVerIncrement `
                    -PackageWildcardExpressions $packageWildcardExpressions
            $res | Should -BeOfType [boolean]
            $res | Should -Be $true
        }
    }

    Context 'User PRs' {
        It 'should return false when processing a normal user-initiated PR' {
            $res = AnyInterestingPRs -Titles @('Fixes a nasty bug!') `
                                    -MaxSemVerIncrement 'patch' `
                                    -PackageWildcardExpressions @("Endjin.*","Corvus.*")
            $res | Should -BeOfType [boolean]
            $res | Should -Be $false  
        }
    }


}