import ArgumentParser
import XCTest

final class ExecutionTests: XCTestCase {
	func testHelp() throws {
		guard #available(macOS 12, *) else { return }
		let helpText = """
			OVERVIEW: Parses conventional commits
			(https://www.conventionalcommits.org/en/v1.0.0)

			Swift Conventional Commit Parser makes use of the following open source
			projects:

			- [Swift Argument Parser](https://github.com/apple/swift-argument-parser)
			- [Swift Dependencies](https://github.com/pointfreeco/swift-dependencies)
			- [Swift Format](https://github.com/apple/swift-format)
			- [SwiftLint](https://github.com/realm/SwiftLint)

			USAGE: swift-conventional-commit-parser <subcommand>

			OPTIONS:
			  --version               Show the version.
			  -h, --help              Show help information.

			SUBCOMMANDS:
			  parse (default)

			  See 'swift-conventional-commit-parser help <subcommand>' for detailed help.
			"""
		try assertExecuteCommand(
			command: "swift-conventional-commit-parser -h", expected: helpText
		)
	}

	func testParseHelp() throws {
		guard #available(macOS 12, *) else { return }
		let helpText = """
			OVERVIEW: 
			Uses the git commits from the repo in which it is executed, up to the most
			recent tag that represents a semantic version, to find conventional
			commits to determine the next semantic version and the release notes.
			Outputs that information in JSON – here is an example:
			```
			{
			  "version" : "1.0.0",
			  "containsBreakingChange" : false,
			  "releaseNotes" : "## [1.0.0] - 1970-01-01\\n\\n### Features\\n* Awesome feature
			(abcdef)\\n\\n### Chores\\n* Change the \\"total\\" field (abcdef)"
			}
			```

			USAGE: swift-conventional-commit-parser parse [--no-formatted-commits-error-message <no-formatted-commits-error-message>] [--strict]

			OPTIONS:
			  -n, --no-formatted-commits-error-message <no-formatted-commits-error-message>
			                          The error message to be shown when no formatted
			                          commits have been found. This is a good place to link
			                          to documentation around how conventional commits work
			                          in your system. (default: No formatted commits)
			  --strict                Apply a strict interpretation of the Conventional
			                          Commit standard. Defaults to false, which makes
			                          `fix:` commits minor version bumps and adds the
			                          `hotfix:` commit for patch version bumps.
			  --version               Show the version.
			  -h, --help              Show help information.
			"""
		try assertExecuteCommand(
			command: "swift-conventional-commit-parser -h parse", expected: helpText
		)
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
		expected: String? = nil,
		exitCode: ExitCode = .success,
		file: StaticString = #file, line: UInt = #line
	) throws {
		try assertExecuteCommand(
			command: command.split(separator: " ").map(String.init),
			expected: expected,
			exitCode: exitCode,
			file: file,
			line: line)
	}

	fileprivate func assertExecuteCommand(
		command: [String],
		expected: String? = nil,
		exitCode: ExitCode = .success,
		file: StaticString = #file, line: UInt = #line
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

			if #available(macOS 10.13, *) {
				guard (try? process.run()) != nil else {
					XCTFail(
						"Couldn't run command process.", file: file,
						line: line)
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
