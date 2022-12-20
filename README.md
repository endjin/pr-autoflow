# pr-autoflow

![build](https://github.com/endjin/dependabot-pr-parser/workflows/build/badge.svg)
[![GitHub license](https://img.shields.io/badge/License-Apache%202-blue.svg)](https://raw.githubusercontent.com/corvus-dotnet/Corvus.Deployment/master/LICENSE)

## dependabot-pr-parser

A GitHub action that extracts information about a [Dependabot](https://docs.github.com/en/github/administering-a-repository/about-github-dependabot-version-updates) PR from its convention-based title.

### Inputs
The action supports the following inputs.

|Name | Required? | Description
|-----|---------|------------
|pr_title| Y |The title of the PR to be parsed
|package_wildcard_expressions| N |A JSON-formatted array of wildcard patterns for dependencies that should be flagged as interesting (e.g. candidates for auto-merging later in the workflow)

### Outputs
The action emits the following output variables.

|Name | Description
|-----|------------
|dependency_name|The package name of the dependency being updated by Dependabot
|from_version|The current version of the dependency
|to_version|The version Dependabot wants to upgrade the dependency to
|folder|The folder where the dependency is updated.
|update_type|The scale of SemVer update being proposed. Possible values: `major`, `minor` or `patch`
|is_matching_package|Flags whether the dependency matched any of the provided package name wildcard patterns

### Example Usage
```
name: sample
on: 
  pull_request:
    types: [opened, reopened]
jobs:
  evaluate_dependabot_pr:
    runs-on: ubuntu-latest
    steps:
    - name: Parse Dependabot PR title
      id: parse_dependabot_pr
      uses: endjin/dependabot-pr-parser@v1
      with:
        pr_title: ${{ github.event.pull_request.title }}
        package_wildcard_expressions: ${{ env.PACKAGE_WILDCARD_EXPRESSIONS }}
      env:
        # Customise this variable to choose which dependencies can be auto-merged
        # NOTE: The values needs to be a JSON-formatted array
        PACKAGE_WILDCARD_EXPRESSIONS: |
          ["Acme.*"]
    - name: Output Dependabot PR information
      runs: |
        echo "dependency_name : ${{ steps.parse_dependabot_pr.outputs.dependency_name }}"
        echo "is_interesting_package : ${{ steps.parse_dependabot_pr.outputs.is_interesting_package }}"
        echo "from_version : ${{ steps.parse_dependabot_pr.outputs.from_version }}"
        echo "to_version : ${{ steps.parse_dependabot_pr.outputs.to_version }}"
        echo "update_type : ${{ steps.parse_dependabot_pr.outputs.update_type }}"
```

## dependabot-pr-watcher

A GitHub action that watches for open [Dependabot](https://docs.github.com/en/github/administering-a-repository/about-github-dependabot-version-updates) PRs to complete.

### Inputs
The action supports the following inputs.

|Name | Required? | Description
|-----|---------|------------
|pr_titles| Y |Stringified JSON array of PR titles.
|max_semver_increment| N | The maximum SemVer increment to watch for.
|package_wildcard_expressions| N |Stringified JSON array of wildcard expressions used to filter which dependencies to watch for

### Outputs
The action emits the following output variables.

|Name | Description
|-----|------------
|is_complete|Flags whether all matching Dependabot PRs have completed.

## Dependencies

```mermaid
graph TD;
  repo(Endjin.GitHubActions.PowerShell)-->docker(Container Image);
  docker-->action(pr-autoflow GitHub Actions)
  action-->workflow(pr-autoflow GitHub Workflows)
```

## Endjin.GitHubActions.PowerShell
- [x] Update PowerShell base image
- [x] Migrate any references to `set-output` workflow commands
- [ ] Migrate to scripted build
## pr-autoflow
- [ ] Update to latest Endjin.GitHubActions image
- [ ] Enable 'Verbose' mode when workflow run in debug mode
- [ ] Add more verbose logging where needed
- [ ] Migrate to scripted build
## Endjin.CodeOps
- [ ] Update to latest Endjin.GitHubActions module
- [ ] Migrate any references to `set-output` workflow commands
- [ ] Migrate to scripted build
## Endjin.RecommendedPractices.Build
- [ ] Add support for publishing to DockerHub
- [ ] Detect when GitHub CLI isn't available and have a fallback
## Workflows
- [ ] Apply updated `auto_release`
- [ ] Upgrade other actions (e.g. `checkout`, `github-script` etc.)
- [ ] Migrate any references to `set-output` workflow commands
- [ ] Investigate distinguishing human PRs from 'dependabot' PRs, so human PRs are never blocked for release
- [ ] Move from .github to 'endjin-codeops'
