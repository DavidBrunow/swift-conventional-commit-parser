import ArgumentParser
import XCTest

final class ExecutionTests: XCTestCase {
	override func setUp() {
		super.setUp()

		guard FileManager.default.fileExists(atPath: .fixturesPath) else {
			continueAfterFailure = false
			XCTFail(
				"Fixtures path does not exist. Run `create_fixtures.sh` script at root of repo."
			)
			return
		}
	}

	func testHelp() throws {
		guard #available(macOS 12, *) else { return }
		let helpText = """
			OVERVIEW: Parses conventional commits
			(https://www.conventionalcommits.org/en/v1.0.0)

			Swift Conventional Commit Parser uses the following open source projects:

			- [Swift Argument Parser](https://github.com/apple/swift-argument-parser)
			- [Swift Dependencies](https://github.com/pointfreeco/swift-dependencies)
			- [Swift Format](https://github.com/apple/swift-format)
			- [SwiftLint](https://github.com/realm/SwiftLint)

			USAGE: swift-conventional-commit-parser <subcommand>

			OPTIONS:
			  --version               Show the version.
			  -h, --help              Show help information.

			SUBCOMMANDS:
			  merge-request
			  pull-request
			  release

			  See 'swift-conventional-commit-parser help <subcommand>' for detailed help.
			"""
		try assertExecuteCommand(
			command: "swift-conventional-commit-parser -h", expected: helpText
		)
	}

	func testPullRequestHelp() throws {
		guard #available(macOS 12, *) else { return }
		let helpText = """
			OVERVIEW: 
			Uses the git commits from the repo, and current branch, in which it is
			executed, up to the most recent tag that represents a semantic version, to
			find conventional commits that only exist on the current branch to
			determine the next semantic version and the release notes. Outputs that
			information in JSON – here is an example:
			```
			{
			  "bumpType" : "minor",
			  "releaseNotes" : "## [1.1.0] - 1970-01-01\\n\\n### Features\\n* Awesome feature
			(abcdef)\\n\\n### Chores\\n* Change the \\"total\\" field (abcdef)",
			  "version" : "1.1.0"
			}
			```

			If no conventional commits are found, exits early with a non-zero exit
			code with "Error:" followed by the message provided in the
			`noFormattedCommitsErrorMessage` option, defaulting to
			"No formatted commits".

			USAGE: swift-conventional-commit-parser pull-request --target-branch <target-branch> [--no-formatted-commits-error-message <no-formatted-commits-error-message>] [--hide-commit-hashes] [--strict]

			OPTIONS:
			  -t, --target-branch <target-branch>
			                          Target branch for the pull request. Used to figure
			                          out which commits are on the source branch.
			  -n, --no-formatted-commits-error-message <no-formatted-commits-error-message>
			                          Error message to be shown when no formatted commits
			                          have been found. This is a good place to link to
			                          documentation around how conventional commits work in
			                          your system. (default: No formatted commits)
			  --hide-commit-hashes    Removes commit hashes from release notes. I use it
			                          for integration testing, but you might want want to
			                          hide the hashes for your own reason. Maybe you were
			                          burned by the crypto craze of the late 2010s and the
			                          mere thought of cryptography gives you to the heeby
			                          jeebies. If so, turn them off!
			  --strict                Apply a strict interpretation of the Conventional
			                          Commit standard. Defaults to false, which makes
			                          `fix:` commits minor version bumps and adds the
			                          `hotfix:` commit for patch version bumps.
			  --version               Show the version.
			  -h, --help              Show help information.
			"""
		try assertExecuteCommand(
			command: "swift-conventional-commit-parser pull-request -h",
			expected: helpText
		)
	}

	func testMergeRequestHelp() throws {
		guard #available(macOS 12, *) else { return }
		let helpText = """
			OVERVIEW: 
			Alias for `pull-request`.

			USAGE: swift-conventional-commit-parser merge-request <subcommand>

			OPTIONS:
			  --version               Show the version.
			  -h, --help              Show help information.

			SUBCOMMANDS:
			  pull-request (default)

			  See 'swift-conventional-commit-parser help merge-request <subcommand>' for detailed help.
			"""
		try assertExecuteCommand(
			command: "swift-conventional-commit-parser merge-request -h",
			expected: helpText
		)
	}

	func testReleaseHelp() throws {
		guard #available(macOS 12, *) else { return }
		let helpText = """
			OVERVIEW: 
			Uses the git commits from the repo in which it is executed, up to the most
			recent tag that represents a semantic version, to find conventional
			commits to determine the next semantic version and the release notes.
			Outputs that information in JSON – here is an example:
			```
			{
			  "bumpType" : "minor",
			  "releaseNotes" : "## [1.1.0] - 1970-01-01\\n\\n### Features\\n* Awesome feature
			(abcdef)\\n\\n### Chores\\n* Change the \\"total\\" field (abcdef)",
			  "version" : "1.1.0"
			}
			```

			If no conventional commits are found, exits early with a non-zero exit
			code with "Error:" followed by the message provided in the
			`noFormattedCommitsErrorMessage` option, defaulting to
			"No formatted commits".

			USAGE: swift-conventional-commit-parser release [--no-formatted-commits-error-message <no-formatted-commits-error-message>] [--hide-commit-hashes] [--strict]

			OPTIONS:
			  -n, --no-formatted-commits-error-message <no-formatted-commits-error-message>
			                          Error message to be shown when no formatted commits
			                          have been found. This is a good place to link to
			                          documentation around how conventional commits work in
			                          your system. (default: No formatted commits)
			  --hide-commit-hashes    Removes commit hashes from release notes. I use it
			                          for integration testing, but you might want want to
			                          hide the hashes for your own reason. Maybe you were
			                          burned by the crypto craze of the late 2010s and the
			                          mere thought of cryptography gives you to the heeby
			                          jeebies. If so, turn them off!
			  --strict                Apply a strict interpretation of the Conventional
			                          Commit standard. Defaults to false, which makes
			                          `fix:` commits minor version bumps and adds the
			                          `hotfix:` commit for patch version bumps.
			  --version               Show the version.
			  -h, --help              Show help information.
			"""
		try assertExecuteCommand(
			command: "swift-conventional-commit-parser release -h",
			expected: helpText
		)
	}

	func testPullRequest_NotGitRepo() throws {
		guard #available(macOS 12, *) else { return }
		let outputText = """
			fatal: not a git repository (or any of the parent directories): .git
			fatal: not a git repository (or any of the parent directories): .git
			Error: No formatted commits
			"""
		try assertExecuteCommand(
			command: "swift-conventional-commit-parser pull-request -t main",
			expected: outputText,
			exitCode: .failure
		)
	}

	func testPullRequest_NoCommits() throws {
		guard #available(macOS 12, *) else { return }
		let outputText = """
			fatal: ambiguous argument 'main': unknown revision or path not in the working tree.
			Use '--' to separate paths from revisions, like this:
			'git <command> [<revision>...] -- [<file>...]'
			Error: No formatted commits
			"""
		try assertExecuteCommand(
			command: "swift-conventional-commit-parser pull-request -t main",
			currentDirectoryPath: .fixturesPath.appending("/GitRepoNoCommits"),
			expected: outputText,
			exitCode: .failure
		)
	}

	func testRelease_NoCommits() throws {
		guard #available(macOS 12, *) else { return }
		let outputText = """
			fatal: your current branch 'main' does not have any commits yet
			Error: No formatted commits
			"""
		try assertExecuteCommand(
			command: "swift-conventional-commit-parser release",
			currentDirectoryPath: .fixturesPath.appending("/GitRepoNoCommits"),
			expected: outputText,
			exitCode: .failure
		)
	}

	func testPullRequest_ChoreOnMain_FeatOnBranch() throws {
		guard #available(macOS 12, *) else { return }
		let outputText = """
			{
			  "bumpType" : "minor",
			  "releaseNotes" : "## [0.1.0] - \(DateFormatter.releaseNotes.string(from: Date()))\\n\\n### Features\\n* My awesome feature\\n\\n### Chores\\n* Add README.md",
			  "version" : "0.1.0"
			}
			"""
		try assertExecuteCommand(
			command:
				"swift-conventional-commit-parser pull-request -t main --hide-commit-hashes",
			currentDirectoryPath: .fixturesPath.appending(
				"/GitRepoChoreOnMainFeatOnBranch"),
			expected: outputText
		)
	}

	func testMergeRequest_ChoreOnMain_FeatOnBranch() throws {
		guard #available(macOS 12, *) else { return }
		let outputText = """
			{
			  "bumpType" : "minor",
			  "releaseNotes" : "## [0.1.0] - \(DateFormatter.releaseNotes.string(from: Date()))\\n\\n### Features\\n* My awesome feature\\n\\n### Chores\\n* Add README.md",
			  "version" : "0.1.0"
			}
			"""
		try assertExecuteCommand(
			command:
				"swift-conventional-commit-parser merge-request -t main --hide-commit-hashes",
			currentDirectoryPath: .fixturesPath.appending(
				"/GitRepoChoreOnMainFeatOnBranch"),
			expected: outputText
		)
	}

	// TODO: integration test where we test commits, but maybe just by length of response? Need something.

	func testPullRequest_ChoreOnMain_NoFormattedCommitOnBranch() throws {
		guard #available(macOS 12, *) else { return }
		let outputText = """
			Error: No formatted commits
			"""
		try assertExecuteCommand(
			command: "swift-conventional-commit-parser pull-request -t main",
			currentDirectoryPath: .fixturesPath.appending(
				"/GitRepoChoreOnMainNoFormattedCommitOnBranch"),
			expected: outputText,
			exitCode: .failure
		)
	}
}

extension DateFormatter {
	fileprivate static var releaseNotes: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}
}

extension String {
	fileprivate static var fixturesPath: String {
		NSString(string: "\(#filePath)").deletingLastPathComponent.appending("/Fixtures")
	}
}

extension XCTest {
	fileprivate var debugURL: URL {
		let bundleURL = Bundle(for: type(of: self)).bundleURL
		return bundleURL.lastPathComponent.hasSuffix("xctest")
			? bundleURL.deletingLastPathComponent()
			: bundleURL
	}

	fileprivate func assertExecuteCommand(
		command: String,
		currentDirectoryPath: String? = nil,
		expected: String? = nil,
		exitCode: ExitCode = .success,
		file: StaticString = #file,
		line: UInt = #line
	) throws {
		try assertExecuteCommand(
			command: command.split(separator: " ").map(String.init),
			currentDirectoryPath: currentDirectoryPath,
			expected: expected,
			exitCode: exitCode,
			file: file,
			line: line)
	}

	fileprivate func assertExecuteCommand(
		command: [String],
		currentDirectoryPath: String? = nil,
		expected: String? = nil,
		exitCode: ExitCode = .success,
		file: StaticString = #file,
		line: UInt = #line
	) throws {
		#if os(Windows)
			throw XCTSkip("Unsupported on this platform")
		#endif

		let arguments = Array(command.dropFirst())
		let commandName = String(command.first ?? "")
		let commandURL = debugURL.appendingPathComponent(commandName)
		guard (try? commandURL.checkResourceIsReachable()) ?? false else {
			XCTFail(
				"No executable at '\(commandURL.standardizedFileURL.path)'.",
				file: file, line: line)
			return
		}

		#if !canImport(Darwin) || os(macOS)
			let process = Process()
			if #available(macOS 10.13, *) {
				process.executableURL = commandURL
			} else {
				process.launchPath = commandURL.path
			}
			process.arguments = arguments

			let output = Pipe()
			process.standardOutput = output
			let error = Pipe()
			process.standardError = error

			if let currentDirectoryPath {
				process.currentDirectoryURL = URL(
					fileURLWithPath: currentDirectoryPath)
			}

			if #available(macOS 10.13, *) {
				guard (try? process.run()) != nil else {
					XCTFail(
						"Couldn't run command process.",
						file: file,
						line: line
					)
					return
				}
			} else {
				process.launch()
			}
			process.waitUntilExit()

			let outputData = output.fileHandleForReading.readDataToEndOfFile()
			let outputActual = (String(data: outputData, encoding: .utf8) ?? "")
				.trimmingCharacters(in: .whitespacesAndNewlines)

			let errorData = error.fileHandleForReading.readDataToEndOfFile()
			let errorActual = (String(data: errorData, encoding: .utf8) ?? "")
				.trimmingCharacters(in: .whitespacesAndNewlines)

			if let expected = expected {
				assertEqualStrings(
					actual: errorActual + outputActual,
					expected: expected,
					file: file,
					line: line)
			}

			XCTAssertEqual(
				process.terminationStatus, exitCode.rawValue, file: file, line: line
			)
		#else
			throw XCTSkip("Not supported on this platform")
		#endif
	}
}

private func assertEqualStrings(
	actual: String,
	expected: String,
	file: StaticString = #file,
	line: UInt = #line
) {
	// If the input strings are not equal, create a simple diff for debugging...
	guard actual != expected else {
		// Otherwise they are equal, early exit.
		return
	}

	let stringComparison: String

	// If collectionDifference is available, use it to make a nicer error message.
	if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
		let actualLines = actual.components(separatedBy: .newlines)
		let expectedLines = expected.components(separatedBy: .newlines)

		let difference = actualLines.difference(from: expectedLines)

		var result = ""

		var insertions = [Int: String]()
		var removals = [Int: String]()

		for change in difference {
			switch change {
			case .insert(let offset, let element, _):
				insertions[offset] = element
			case .remove(let offset, let element, _):
				removals[offset] = element
			}
		}

		var expectedLine = 0
		var actualLine = 0

		while expectedLine < expectedLines.count || actualLine < actualLines.count {
			if let removal = removals[expectedLine] {
				result += "–\(removal)\n"
				expectedLine += 1
			} else if let insertion = insertions[actualLine] {
				result += "+\(insertion)\n"
				actualLine += 1
			} else {
				result += " \(expectedLines[expectedLine])\n"
				expectedLine += 1
				actualLine += 1
			}
		}

		stringComparison = result
	} else {
		stringComparison = """
			Expected:
			\(expected)

			Actual:
			\(actual)
			"""
	}

	XCTFail(
		"Actual output does not match the expected output:\n\(stringComparison)",
		file: file,
		line: line)
}
