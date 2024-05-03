import ArgumentParser
import Dependencies
import GitClient
import SwiftConventionalCommitParser

struct PullRequestCommand: AsyncParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "pull-request",
		discussion:
			"""
			Uses the git commits from the repo, and current branch, in which it is
			executed, up to the most recent tag that represents a semantic version, to
			find conventional commits that only exist on the current branch to
			determine the next semantic version and the release notes. Outputs that
			information in JSON – here is an example:
			```
			{
			  "bumpType" : "minor",
			  "releaseNotes" : "## [1.1.0] - 1970-01-01\\n\\n### Features\\n* Awesome feature (abcdef)\\n\\n### Chores\\n* Change the \\\"total\\\" field (abcdef)",
			  "version" : "1.1.0"
			}
			```

			If no conventional commits are found, exits early with a non-zero exit
			code with "Error:" followed by the message provided in the
			`noFormattedCommitsErrorMessage` option, defaulting to
			"No formatted commits".
			"""
	)

	@Option(
		name: .shortAndLong,
		help:
			"Target branch for the pull request. Used to figure out which commits are on the source branch."
	)
	var targetBranch: String

	@Option(
		name: .shortAndLong,
		help:
			"Error message to be shown when no formatted commits have been found. This is a good place to link to documentation around how conventional commits work in your system."
	)
	var noFormattedCommitsErrorMessage: String = "No formatted commits"

	@Flag(
		name: .long,
		help:
			"Removes commit hashes from release notes. I use it for integration testing, but you might want want to hide the hashes for your own reason. Maybe you were burned by the crypto craze of the late 2010s and the mere thought of cryptography gives you to the heeby jeebies. If so, turn them off!"
	)
	var hideCommitHashes = false

	@Flag(
		help:
			"Apply a strict interpretation of the Conventional Commit standard. Defaults to false, which makes `fix:` commits minor version bumps and adds the `hotfix:` commit for patch version bumps."
	)
	var strict = false

	func run() async throws {
		try withDependencies {
			$0[GitClient.self] = .liveValue
		} operation: {
			@Dependency(GitClient.self) var gitClient

			let releaseNotes = try Parser.releaseNotes(
				gitClient: gitClient,
				targetBranch: targetBranch,
				hideCommitHashes: hideCommitHashes,
				strictInterpretationOfConventionalCommits: strict,
				noFormattedCommitsErrorMessage: noFormattedCommitsErrorMessage
			)

			print("\(releaseNotes.json)")
		}
	}
}
