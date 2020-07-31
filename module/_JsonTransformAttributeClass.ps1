using namespace System.Management.Automation

class JsonTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        $outputData = switch ($inputData) {
            { $_ -is [string] } {
                if ($_.StartsWith('[')) {
                    $_ | ConvertFrom-Json
                }
                elseif ($_.StartsWith('{')) {
                    $_ | ConvertFrom-Json
                }
                else {
                    $_
                }
            }
            default {
                $_
            }
        }

        return $outputData
    }
}