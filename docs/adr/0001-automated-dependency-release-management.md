# Automated Dependency Release Management

## Status

Proposed

## Context

Whilst tools like [Dependabot](https://github.blog/2020-06-01-keep-all-your-packages-up-to-date-with-dependabot/) simplify the process of testing updates to a repository's package dependencies, there can still be signficant coordination work to apply such changes and have the resulting updates cascade through the rest of your software estate.

Before committing a dependency update there are several considerations:
* What type of [semantic version](https://semver.org) increment is this change?
* How confident are we in the repository's tests for catching breaking changes in dependencies?
* How reliable is the publisher's SemVer attribution?
* Should this dependency update trigger a new release?  If so, how should such updates be batched?
* To what extent could this update trigger a cascading update across other repositories?

This ADR describes an automation process that can reduce the burden associated with such updates and their cascading effects, whilst still providing control mechanisms to prevent unrestricted updates.

**NOTE**: *The process, as described, assumes the use GitHub Dependabot (as opposed to the dependabot.io service that has slightly different functionality)*

## Decision

The process for approving, merging and releasing these types of updates can be automated so long as suitable control measures are in-place to manage the different package promotion requirements.

### Concepts

A number of terms are used to describe the process, they are defined as follows:

* `semver-increment`: The scale of a given change as indicated by the change in the semantic version (i.e. patch, minor, major)
* `auto-approve`: The process of a CI/CD bot approving a pull request
* `auto-merge`: The process of a pull request being merged by a bot, once in a mergeable state (e.g. passing checks, approved etc.)
* `auto-merge-candidate`: A pull request that is approved for `auto-merge`
* `auto-release`: The process of triggering the release pipeline of the consuming project (e.g. creating a git tag)
* `auto-release-candidate`: A pull request that is approved for `auto-release`
* `no-release`: An override mechanism for suppressing the `auto-release` behaviour
* `release-pending`: The state a pull request can be in when it is approved for `auto-release`

### Principles

These set out the basic requirements for this process we wish to automate.

1. Dependabot updates can utilise `auto-approve` and `auto-merge`, based on an allow list
1. Dependabot updates otherwise approved for `auto-merge` can be opted-out based on their `semver-increment` - by default, 'major' changes are ignored by this process
1. Dependabot updates approved for `auto-merge` can additionally utilise `auto-release`, based on an allow list
1. Regular pull requests must never utilise `auto-approve`
1. Regular pull requests will, by default, utilise `auto-release`
1. Regular pull requests may opt-out of `auto-release`
1. All `auto-release-candidate` pull requests must be batched together, to avoid unnecesary release churn

The process that implements these mechanisms is illustrated in the following flowchart diagram:

![pr-autoflow: High-Level Process Flow][flowchart]


## Consequences

* Overhead of maintaining external dependencies is reduced, provided adequate automated test coverage is available to validate such changes
* Control over which dependencies benefit from this automation whilst ensuring that, for example, major changes to such dependencies still require manual approval
* Streamlines a continuous delivery process for the typical pull request workflow
* By combining `auto-merge` with `auto-release`, dependency updates can automatically propogate through a hierarchy of related repositories with manual intervention only by exception

## Future Considerations

* Add instrumentation to this process to faciliate centralised tracking of metrics related to the propogation of updates across repositories

[flowchart]: /docs/images/flowchart.jpg "pr-autoflow: High-Level Process Flow"