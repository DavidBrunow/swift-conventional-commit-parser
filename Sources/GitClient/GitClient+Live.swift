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
			arguments: arguments,
			environmentVariables: [:],
			outputFile: nil
		)

		return log.components(separatedBy: "-@-@-@-@-@-@-@-@")
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			.filter { $0.isEmpty == false }
			.compactMap { GitCommit($0) }
	} tag: {
		let tag = shell(
			command: "git tag",
			arguments: [],
			environmentVariables: [:],
			outputFile: nil
		)

		return tag.split(separator: "\n").map { String($0) }
	}
}

private func shell(
	command: String,
	arguments: [String],
	environmentVariables: [String: String],
	outputFile: String?
) -> String {
	let scriptOutputFile: String

	if let outputFile = outputFile {
		scriptOutputFile = " > \(outputFile)"
	} else {
		scriptOutputFile = ""
	}

	let script = "\(command) \(arguments.joined(separator: " "))" + scriptOutputFile

	let task = Process()
	task.launchPath = "/bin/sh"
	task.arguments = ["-c", script]
	task.environment = mergeEnvs(
		localEnv: environmentVariables, processEnv: ProcessInfo.processInfo.environment)
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
	return (String(data: data, encoding: .utf8) ?? "").trimmingCharacters(
		in: .whitespacesAndNewlines)
}

private func mergeEnvs(localEnv: [String: String], processEnv: [String: String]) -> [String: String]
{
	localEnv.merging(processEnv) { _, envString -> String in
		envString
	}
}
