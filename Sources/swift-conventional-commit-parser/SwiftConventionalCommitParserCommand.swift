import ArgumentParser

/// Collects the command line options that were passed to
/// `swift-conventional-commit-parser` and dispatches to the appropriate
/// subcommand.
@main
struct SwiftConventionalCommitParserCommand: AsyncParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "swift-conventional-commit-parser",
		abstract:
			"Parses conventional commits (https://www.conventionalcommits.org/en/v1.0.0)",
		discussion: """
			Swift Conventional Commit Parser uses the following open source projects:

			- [Swift Argument Parser](https://github.com/apple/swift-argument-parser)
			- [Swift Dependencies](https://github.com/pointfreeco/swift-dependencies)
			- [Swift Format](https://github.com/apple/swift-format)
			- [SwiftLint](https://github.com/realm/SwiftLint)
			""",
		version: "0.0.0",
		subcommands: [
			MergeRequestCommand.self,
			PullRequestCommand.self,
			ReleaseCommand.self,
		]
	)
}
