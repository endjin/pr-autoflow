$here = Split-Path -Parent $PSCommandPath
Invoke-pester -Script @{Path=$here; Parameters=@{localMode=$true}}