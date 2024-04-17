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
		subcommands: [
			ParseCommand.self
		],
		defaultSubcommand: ParseCommand.self
	)
}
