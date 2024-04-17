import ArgumentParser
import Dependencies
import GitClient
import SwiftConventionalCommitParser

struct ParseCommand: AsyncParsableCommand {
	@Flag(
		help:
			"Apply a strict interpretation of the Conventional Commit standard. Defaults to false, which makes `fix:` commits minor version bumps and adds the `hotfix:` commit for patch version bumps."
	)
	var strict = false

	func run() async throws {
		try withDependencies {
			$0[GitClient.self] = .liveValue
		} operation: {
			let releaseNotes = try Parser.releaseNotes(
				strictInterpretationOfConventionalCommits: strict
			)

			print("\(releaseNotes.json)")
		}
	}
}
