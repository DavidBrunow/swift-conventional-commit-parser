import Dependencies
import XCTest

@testable import Model

class ReleaseNotesTests: XCTestCase {
	func testReleaseNotes() throws {
		try withDependencies {
			$0.date.now = Date(timeIntervalSince1970: 0)
		} operation: {
			XCTAssertEqual(
				ReleaseNotes(
					version: SemanticVersion(major: 1, minor: 1, patch: 0),
					conventionalCommits: [
						try XCTUnwrap(
							ConventionalCommit(
								commit: .mockAwesomeChore
							)
						),
						try XCTUnwrap(
							ConventionalCommit(
								commit: .mockAwesomeFeature
							)
						),
						try XCTUnwrap(
							ConventionalCommit(
								commit: .mockAwesomeHotfix
							)
						),
					]
				).markdown,
				"""
				## [1.1.0] - 1970-01-01

				### Features
				* Awesome feature (abcdef)

				### Hotfixes
				* Awesome hotfix (abcdef)

				### Chores
				* Awesome chore (abcdef)
				"""
			)
		}
	}

	func testReleaseNotesWithBreakingChangeFeature() throws {
		try withDependencies {
			$0.date.now = Date(timeIntervalSince1970: 0)
		} operation: {
			XCTAssertEqual(
				ReleaseNotes(
					version: SemanticVersion(major: 1, minor: 0, patch: 0),
					conventionalCommits: [
						try XCTUnwrap(
							ConventionalCommit(
								commit: .mockAwesomeChore)),
						try XCTUnwrap(
							ConventionalCommit(
								commit:
									.mockAwesomeFeatureBreakingChange
							)),
					]
				).markdown,
				"""
				## [1.0.0] - 1970-01-01

				### Features
				* [**BREAKING CHANGE**] Awesome feature (abcdef)

				### Chores
				* Awesome chore (abcdef)
				"""
			)
		}
	}

	func testReleaseNotesWithBreakingChangeBugfix() throws {
		try withDependencies {
			$0.date.now = Date(timeIntervalSince1970: 0)
		} operation: {
			XCTAssertEqual(
				ReleaseNotes(
					version: SemanticVersion(major: 1, minor: 0, patch: 0),
					conventionalCommits: [
						try XCTUnwrap(
							ConventionalCommit(
								commit: .mockAwesomeChore
							)
						),
						try XCTUnwrap(
							ConventionalCommit(
								commit:
									.mockAwesomeBugfixBreakingChange
							)
						),
					]
				).markdown,
				"""
				## [1.0.0] - 1970-01-01

				### Bug Fixes
				* [**BREAKING CHANGE**] Awesome bug fix (abcdef)

				### Chores
				* Awesome chore (abcdef)
				"""
			)
		}
	}

	func testReleaseNotesWithCommitTypeThatDoesNotNeedPluralization() throws {
		try withDependencies {
			$0.date.now = Date(timeIntervalSince1970: 0)
		} operation: {
			XCTAssertEqual(
				ReleaseNotes(
					version: SemanticVersion(major: 1, minor: 0, patch: 0),
					conventionalCommits: [
						try XCTUnwrap(
							ConventionalCommit(
								commit: .mockAwesomeChore
							)
						),
						try XCTUnwrap(
							ConventionalCommit(
								commit:
									GitCommit(
										hash: "abcdef",
										subject:
											"docs: Improve public api documentation"
									)
							)
						),
					]
				).markdown,
				"""
				## [1.0.0] - 1970-01-01

				### Chores
				* Awesome chore (abcdef)

				### Docs
				* Improve public api documentation (abcdef)
				"""
			)
		}
	}

	func testReleaseNotesOrderWithChoreBeforeHotfix() throws {
		try withDependencies {
			$0.date.now = Date(timeIntervalSince1970: 0)
		} operation: {
			XCTAssertEqual(
				ReleaseNotes(
					version: SemanticVersion(major: 1, minor: 0, patch: 0),
					conventionalCommits: [
						try XCTUnwrap(
							ConventionalCommit(
								commit: .mockAwesomeChore
							)
						),
						try XCTUnwrap(
							ConventionalCommit(
								commit:
									.mockAwesomeHotfix
							)
						),
					]
				).markdown,
				"""
				## [1.0.0] - 1970-01-01

				### Hotfixes
				* Awesome hotfix (abcdef)

				### Chores
				* Awesome chore (abcdef)
				"""
			)
		}
	}

	func testReleaseNotesOrderWithChoreBeforeBugFix() throws {
		try withDependencies {
			$0.date.now = Date(timeIntervalSince1970: 0)
		} operation: {
			XCTAssertEqual(
				ReleaseNotes(
					version: SemanticVersion(major: 1, minor: 0, patch: 0),
					conventionalCommits: [
						try XCTUnwrap(
							ConventionalCommit(
								commit: .mockAwesomeChore
							)
						),
						try XCTUnwrap(
							ConventionalCommit(
								commit:
									.mockAwesomeBugfix
							)
						),
					]
				).markdown,
				"""
				## [1.0.0] - 1970-01-01

				### Bug Fixes
				* Awesome bug fix (abcdef)

				### Chores
				* Awesome chore (abcdef)
				"""
			)
		}
	}

	func testReleaseNotesWithQuoteInCommit() throws {
		try withDependencies {
			$0.date.now = Date(timeIntervalSince1970: 0)
		} operation: {
			let json = ReleaseNotes(
				version: SemanticVersion(major: 1, minor: 0, patch: 0),
				conventionalCommits: [
					try XCTUnwrap(
						ConventionalCommit(
							commit: try XCTUnwrap(
								GitCommit(
									"""
									abcdef \(GitCommit.ParsingConstants.fieldSeparator) chore: Change the "total" field
									"""
								)
							)
						)
					),
					try XCTUnwrap(
						ConventionalCommit(commit: .mockAwesomeFeature)),
				]
			).json
			let expected = """
				{
				  "version" : "1.0.0",
				  "containsBreakingChange" : false,
				  "releaseNotes" : "## [1.0.0] - 1970-01-01\\\\n\\\\n### Features\\\\n* Awesome feature (abcdef)\\\\n\\\\n### Chores\\\\n* Change the \\\"total\\\" field (abcdef)"
				}
				"""

			XCTAssertEqual(
				json,
				expected
			)
			let data = try XCTUnwrap(expected.data(using: .utf8))
			let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

			XCTAssertEqual(
				String(
					data: try JSONSerialization.data(
						withJSONObject: jsonObject as Any,
						options: [.prettyPrinted]
					),
					encoding: .utf8
				),
				expected
			)
		}
	}
}
