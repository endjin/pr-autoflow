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
    
    Write-Output ("`n::set-output name={0}::{1}" -f $Name, $Value)
}