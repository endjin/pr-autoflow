$ErrorActionPreference = 'Stop'
$dockerfile = 'Dockerfile'     # builds the container from your working copy
$imageName = 'dependabot-pr-parser'
docker build --no-cache -t $imageName -f $dockerfile .
if ($LASTEXITCODE -ne 0) { throw 'Error building docker image' }

$actionParams = @(
    '-Title'
    '"Bump Corvus.Extensions.Newtonsoft.Json from 0.9.0 to 1.0.0 in /Solutions/dependency-playground"'
    '-PackageWildCardExpressions'
    '[\"Corvus.*\"]'
)

$actionArgs = $actionParams -join ' '
Write-Host "Args: $actionArgs"

# Use '%--' to prevent powershell from pre-parsing the arguments we are sending to Docker
$dockerCmd = "docker run -it --rm $imageName --% $actionArgs -Verbose"
Write-Host "DockerCmd: $dockerCmd"
Invoke-Expression $dockerCmd
exit $LASTEXITCODE