# dependabot-pr-parser

[![GitHub license](https://img.shields.io/badge/License-Apache%202-blue.svg)](https://raw.githubusercontent.com/corvus-dotnet/Corvus.Deployment/master/LICENSE)

A GitHub action that extracts information about a [Dependabot](https://docs.github.com/en/github/administering-a-repository/about-github-dependabot-version-updates) PR from its convention-based title.

## Inputs
The action supports the following inputs.

|Name | Required? | Description
|-----|---------|------------
|pr_title| Y |The title of the PR to be parsed
|package_filter| Y |A JSON-formatted array of wildcard patterns for dependencies that should be flagged as interesting (e.g. candidates for auto-merging later in the workflow)

## Outputs
The action emits the following output variables.

|Name | Description
|-----|------------
|dependency_name|The package name of the dependency being updated by Dependabot
|is_interesting_package|Whether the package name matched the `package_filter` input. Possible values: `True` or `False`
|from_version|The current version of the dependency
|to_version|The version Dependabot wants to upgrade the dependency to
|update_type|The scale of SemVer update being proposed. Possible values: `major`, `minor` or `patch`

## Example Usage
```
job:
  evaluate_dependabot_pr:
    runs-on: ubuntu-latest
    steps:
    - name: Parse Dependabot PR title
      id: parse_dependabot_pr
      uses: endjin/dependabot-pr-parser@v1
      with:
        pr_title: ${{ github.event.pull_request.title }}
        package_filter: ${{ env.PACKAGES_FILTER }}
      env:
        # Customise this variable to choose which dependencies can be auto-merged
        # NOTE: The values needs to be a JSON-formatted array
        PACKAGES_FILTER: |
          ["Acme.*"]
    - name: Output Dependabot PR information
      runs: |
        echo "dependency_name : ${{ steps.parse_dependabot_pr.outputs.dependency_name }}"
        echo "is_interesting_package : ${{ steps.parse_dependabot_pr.outputs.is_interesting_package }}"
        echo "from_version : ${{ steps.parse_dependabot_pr.outputs.from_version }}"
        echo "to_version : ${{ steps.parse_dependabot_pr.outputs.to_version }}"
        echo "update_type : ${{ steps.parse_dependabot_pr.outputs.update_type }}"
```
