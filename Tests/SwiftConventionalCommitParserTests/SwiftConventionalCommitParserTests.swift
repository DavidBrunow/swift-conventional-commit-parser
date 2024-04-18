import Dependencies
import GitClient
import Model
import SwiftConventionalCommitParser
import XCTest

class SwiftConventionalCommitParserTests: XCTestCase {
	func testParseNextVersionNoTagsNoLogs() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertThrowsError(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: false
				).version
			) {
				XCTAssertEqual($0 as? ParserError, ParserError.noFormattedCommits)
			}
		}
	}

	func testParseNextVersionNoTagsNoLogsStrict() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertThrowsError(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: true
				).version
			) {
				XCTAssertEqual($0 as? ParserError, ParserError.noFormattedCommits)
			}
		}
	}

	func testParseNextVersionNoTagsSingleFeatCommit() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeFeature
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: false
				).version,
				SemanticVersion(major: 0, minor: 1, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsSingleFeatCommitStrict() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeFeature
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: true
				).version,
				SemanticVersion(major: 0, minor: 1, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsSingleFixCommit() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeBugfix
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: false
				).version,
				SemanticVersion(major: 0, minor: 1, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsSingleFixCommitStrict() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeBugfix
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: true
				).version,
				SemanticVersion(major: 0, minor: 0, patch: 1)
			)
		}
	}

	func testParseNextVersionNoTagsSingleHotfixCommit() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeHotfix
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: false
				).version,
				SemanticVersion(major: 0, minor: 0, patch: 1)
			)
		}
	}

	func testParseNextVersionNoTagsSingleHotfixCommitStrict() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeHotfix
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: true
				).version,
				SemanticVersion(major: 0, minor: 0, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsSingleFeatBreakingChangeCommit() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeFeatureBreakingChange
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: false
				).version,
				SemanticVersion(major: 1, minor: 0, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsSingleFeatBreakingChangeCommitStrict() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeFeatureBreakingChange
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: true
				).version,
				SemanticVersion(major: 1, minor: 0, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsSingleFixBreakingChangeCommit() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeBugfixBreakingChange
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: false
				).version,
				SemanticVersion(major: 1, minor: 0, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsSingleFixBreakingChangeCommitStrict() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeBugfixBreakingChange
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: true
				).version,
				SemanticVersion(major: 1, minor: 0, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsSingleHotfixBreakingChangeCommit() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					GitCommit(hash: "abcdef", subject: "hotfix!: My bugfix")
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: false
				).version,
				SemanticVersion(major: 1, minor: 0, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsSingleHotfixBreakingChangeCommitStrict() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					GitCommit(hash: "abcdef", subject: "hotfix!: My bugfix")
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: false
				).version,
				SemanticVersion(major: 1, minor: 0, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsBreakingChangeMultipleCommits() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeBugfixBreakingChange,
					.mockAwesomeChore,
					.mockAwesomeFeature,
					.mockAwesomeHotfix,
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: false
				).version,
				SemanticVersion(major: 1, minor: 0, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsBreakingChangeMultipleCommitsStrict() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeBugfixBreakingChange,
					.mockAwesomeChore,
					.mockAwesomeFeature,
					.mockAwesomeHotfix,
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: true
				).version,
				SemanticVersion(major: 1, minor: 0, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsFeatMultipleCommits() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeChore,
					.mockAwesomeFeature,
					.mockAwesomeHotfix,
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: false
				).version,
				SemanticVersion(major: 0, minor: 1, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsFeatMultipleCommitsStrict() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeChore,
					.mockAwesomeFeature,
					.mockAwesomeHotfix,
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: true
				).version,
				SemanticVersion(major: 0, minor: 1, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsFixMultipleCommits() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeChore,
					.mockAwesomeBugfix,
					.mockAwesomeHotfix,
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: false
				).version,
				SemanticVersion(major: 0, minor: 1, patch: 0)
			)
		}
	}

	func testParseNextVersionNoTagsFixMultipleCommitsStrict() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeChore,
					.mockAwesomeBugfix,
					.mockAwesomeHotfix,
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: true
				).version,
				SemanticVersion(major: 0, minor: 0, patch: 1)
			)
		}
	}

	func testParseNextVersionNoTagsHotfixMultipleCommits() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeChore,
					.mockAwesomeHotfix,
					.mockAwesomeHotfix,
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: false
				).version,
				SemanticVersion(major: 0, minor: 0, patch: 1)
			)
		}
	}

	func testParseNextVersionNoTagsHotfixMultipleCommitsStrict() throws {
		try withDependencies {
			$0[GitClient.self] = GitClient { _ in
				[
					.mockAwesomeChore,
					.mockAwesomeHotfix,
					.mockAwesomeHotfix,
				]
			} tag: {
				[]
			}
		} operation: {
			XCTAssertEqual(
				try Parser.releaseNotes(
					strictInterpretationOfConventionalCommits: true
				).version,
				SemanticVersion(major: 0, minor: 0, patch: 0)
			)
		}
	}
}
