function ParsePrTitle
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Title
    )

    Write-Verbose "Parsing PR: $Title"

    $pattern = "Bump (.*) from (.*) to (.*) in (.*)"

    $res = [System.Text.RegularExpressions.Regex]::Matches($Title, $pattern)

    if ($res.Count -gt 0) {
        # log debug info
        $res.Groups | Format-Table | Out-String | Write-Verbose

        $res.Groups[1].Value
        $res.Groups[2].Value
        $res.Groups[3].Value
        $res.Groups[4].Value
    }
    else {
        throw ("Could not parse the PR title '{0}' - must be a PR raised by Dependabot" -f $Title)
    }
}