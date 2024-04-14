import ArgumentParser
import Dependencies
import GitClient
import SwiftConventionalCommitParser

struct ParseCommand: AsyncParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "parse",
		discussion:
			"""
			Uses the git commits from the repo in which it is executed, up to the most
			recent tag that represents a semantic version, to find conventional
			commits to determine the next semantic version and the release notes.
			Outputs that information in JSON – here is an example:
			```
			{
			  "version" : "1.0.0",
			  "containsBreakingChange" : false,
			  "releaseNotes" : "## [1.0.0] - 1970-01-01\\n\\n### Features\\n* Awesome feature (abcdef)\\n\\n### Chores\\n* Change the \\\"total\\\" field (abcdef)"
			}
			```
			"""
	)

	@Option(
		name: .shortAndLong,
		help:
			"The error message to be shown when no formatted commits have been found. This is a good place to link to documentation around how conventional commits work in your system."
	)
	var noFormattedCommitsErrorMessage: String = "No formatted commits"

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
				strictInterpretationOfConventionalCommits: strict,
				noFormattedCommitsErrorMessage: noFormattedCommitsErrorMessage
			)

			print("\(releaseNotes.json)")
		}
	}
}
