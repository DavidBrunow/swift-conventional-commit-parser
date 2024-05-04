import Foundation
import Model

extension GitClient {
	/// No overview available.
	public static let liveValue: GitClient = GitClient { logType in
		let arguments: [String]
		switch logType {
		case let .branch(targetBranch):
			arguments = [
				"--no-pager",
				"log",
				"--all",
				"--not \(targetBranch)",
				"--no-merges",
				"--pretty=\"%h \(GitCommit.ParsingConstants.fieldSeparator) %s \(GitCommit.ParsingConstants.fieldSeparator) %b \n-@-@-@-@-@-@-@-@\n\"",
			]
		case let .tag(tag):
			arguments = [
				"--no-pager",
				"log",
				// swiftlint:disable:next force_unwrapping
				tag == nil ? "" : "\(tag!)..HEAD",
				"--no-merges",
				"--pretty=\"%h \(GitCommit.ParsingConstants.fieldSeparator) %s \(GitCommit.ParsingConstants.fieldSeparator) %b \n-@-@-@-@-@-@-@-@\n\"",
			]
		}

		let log = shell(
			command: "git",
			arguments: arguments
		)

		return log.components(separatedBy: "-@-@-@-@-@-@-@-@")
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			.filter { $0.isEmpty == false }
			.compactMap { GitCommit($0) }
	} tag: {
		let tag = shell(
			command: "git tag",
			arguments: []
		)

		return tag.split(separator: "\n").map { String($0) }
	}
}

private func shell(
	command: String,
	arguments: [String]
) -> String {

	let script = "\(command) \(arguments.joined(separator: " "))"

	let task = Process()
	task.launchPath = "/bin/sh"
	task.arguments = ["-c", script]
	task.environment = ProcessInfo.processInfo.environment
	task.currentDirectoryPath = FileManager.default.currentDirectoryPath

	let pipe = Pipe()
	task.standardOutput = pipe

	do {
		try task.run()
	} catch let error as NSError {
		print(error.localizedDescription)
		return ""
	}

	let data = pipe.fileHandleForReading.readDataToEndOfFile()
	return (String(data: data, encoding: .utf8) ?? "")
		.trimmingCharacters(in: .whitespacesAndNewlines)
}
