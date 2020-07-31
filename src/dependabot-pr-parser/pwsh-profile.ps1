Write-Host 'Loading profile...'

if ( !(Get-Module dependabot-pr-parser)) {
    if ( !(Test-Path /tmp/module/dependabot-pr-parser.psm1) ) {
        throw 'Unable to locate the dependabot-pr-parser module - something went wrong!'
    }
    Import-Module /tmp/module/dependabot-pr-parser.psd1 -DisableNameChecking
}
