import Foundation
import Model

extension GitClient {
	/// No overview available.
	public static let liveValue: GitClient = GitClient { logType in
		// Check if we're in a git repository
		guard FileManager.default.fileExists(atPath: ".git") else {
			throw GitError.repositoryNotFound
		}
		let arguments: [String]
		switch logType {
		case let .branch(targetBranch):
			arguments = [
				"--no-pager",
				"log",
				"\(targetBranch)..",
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

		let (output, exitCode) = shell(
			command: "git",
			arguments: arguments
		)
		
		guard exitCode == 0 else {
			throw GitError.gitCommandFailed("git \(arguments.joined(separator: " "))", exitCode: exitCode)
		}

		return output.components(separatedBy: "-@-@-@-@-@-@-@-@")
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			.filter { $0.isEmpty == false }
			.compactMap { GitCommit($0) }
	} tag: {
		// Check if we're in a git repository
		guard FileManager.default.fileExists(atPath: ".git") else {
			throw GitError.repositoryNotFound
		}
		
		let (output, exitCode) = shell(
			command: "git tag --merged",
			arguments: []
		)
		
		guard exitCode == 0 else {
			throw GitError.gitCommandFailed("git tag --merged", exitCode: exitCode)
		}

		return output.split(separator: "\n").map { String($0) }
	}
}

private func shell(
	command: String,
	arguments: [String]
) -> (output: String, exitCode: Int) {
	let script = "\(command) \(arguments.joined(separator: " "))"

	let task = Process()
	task.launchPath = "/bin/sh"
	task.arguments = ["-c", script]
	task.environment = ProcessInfo.processInfo.environment
	task.currentDirectoryPath = FileManager.default.currentDirectoryPath

	let pipe = Pipe()
	task.standardOutput = pipe
	let errorPipe = Pipe()
	task.standardError = errorPipe

	try? task.run()
	task.waitUntilExit()

	let data = pipe.fileHandleForReading.readDataToEndOfFile()
	let output = (String(data: data, encoding: .utf8) ?? "")
		.trimmingCharacters(in: .whitespacesAndNewlines)
	
	return (output: output, exitCode: Int(task.terminationStatus))
}
