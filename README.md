# Swift Conventional Commit Parser

CI tool that parses [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/#specification),
enabling automation of the release process.

## Workflow

Swift Conventional Commit Parser is meant to be used in two different parts of
your CI tooling.

1. On pull request CI, so that the release notes can be shown on the pull request
as a comment, which I prefer to do using [Danger Swift](https://github.com/danger/swift).
Showing the release notes on the pull request allows the author and any
reviewers to ensure that the release notes match their expectations. This also
allows errors to be shown when commits are not properly formatted.
1. On merges to the trunk branch, so that a new release can be created, the
version can be bumped, the changelog can be updated, and a tag can be added and
pushed for the new release – all automatically.

Swift Conventional Commit Parser returns JSON that looks like this:

```json
{
  "version" : "1.0.0",
  "containsBreakingChange" : false,
  "releaseNotes" : "## [1.0.0] - 1970-01-01\n\n### Features\n* Awesome feature
(abcdef)\n\n### Chores\n* Change the \"total\" field (abcdef)"
}
```

Let's talk through these properties and how they can be used.

### `version`

The `version` property allows CI to create a tag for the new version. 

### `containsBreakingChange`

The `containsBreakingChange` property can be used alongside other tools that can
determine whether the code contains breaking changes. Together, they can fail
the build if the code contains breaking changes but the formatted commits do not
indicate there are breaking changes.

### `releaseNotes`

The `releaseNotes` property can be used to report back to the pull request and
to update the changelog.

## Tips on Using Conventional Commits

Conventional commits are meant to solve two problems, which informs how I like
recommend using them:

1. Specifying the next semantic version
1. Providing useful information for release notes

With these problems in mind, I try to keep everything else simple. I only use
these types:

* `feat` / `feat!`: For code additions unrelated to bugs and breaking changes
for the same.
* `fix` / `fix!`: For changes related to bugs and breaking changes related to
bugs.
* `hotfix`: For rare situations where I'm making tiny fixes that need to be
squeezed between minor versions.
* `chore`: For everything that doesn't affect production code, and therefore
does not need a new release. Some examples: Adding tests, changes to example
apps, updates to documentation that don't need a release.

So that leaves the useful information for release notes part. Release notes
should be targeted at users. While it is useful to be able to go back through a
your own changelog to see what has been done in the past, it is most useful for
users to know what is in each release. I try to keep that in mind when writing
my formatted commits. They describe the overall change and they don't include
extraneous information about which ticket was being implemented.

## Acknowledgements

Swift Conventional Commit Parser makes use of the following open source
projects:

 - [Swift Argument Parser](https://github.com/apple/swift-argument-parser)
 - [Swift Dependencies](https://github.com/pointfreeco/swift-dependencies)
 - [Swift Format](https://github.com/apple/swift-format)
 - [SwiftLint](https://github.com/realm/SwiftLint)
