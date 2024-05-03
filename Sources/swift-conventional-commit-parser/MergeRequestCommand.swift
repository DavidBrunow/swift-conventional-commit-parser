import ArgumentParser

struct MergeRequestCommand: AsyncParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "merge-request",
		discussion:
			"""
			Alias for `pull-request`.
			""",
		subcommands: [PullRequestCommand.self],
		defaultSubcommand: PullRequestCommand.self
	)
}
