$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $PSCommandPath

$moduleTests = & "$here/module/run-tests.ps1"

$actionTests = & "$here/actions/run-tests.ps1"

$total = $moduleTests.TotalCount + $actionTests.TotalCount
$passed = $moduleTests.PassedCount + $actionTests.PassedCount
$failed = $moduleTests.FailedCount + $actionTests.FailedCount
$skipped = $moduleTests.SkippedCount + $actionTests.SkippedCount

Write-Host "`nTEST SUMMARY"
Write-Host "Total Tests        : $total"
Write-Host "Total Passed Tests : $passed"
Write-Host "Total Failed Tests : $failed"
Write-Host "Total Skipped Tests: $skipped"

if ($failed -gt 0) {
    Write-Host "Some tests failed - check previous logs"
    exit 1
}