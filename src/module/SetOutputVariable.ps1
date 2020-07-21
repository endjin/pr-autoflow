function SetOutputVariable
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Name,

        [Parameter(Mandatory=$true)]
        [string]
        $Value
    )
    
    Write-Output ("::set-output {0}={1}" -f $Name, $Value)
}