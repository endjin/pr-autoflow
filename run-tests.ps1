$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $PSCommandPath

& "$here/module/run-tests.ps1"
& "$here/actions/run-tests.ps1"