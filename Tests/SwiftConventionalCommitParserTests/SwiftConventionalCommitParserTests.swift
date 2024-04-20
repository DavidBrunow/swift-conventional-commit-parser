import GitClient
import Model
import SwiftConventionalCommitParser
import XCTest

class SwiftConventionalCommitParserTests: XCTestCase {
	func testParseNextVersionNoTagsNoLogs() throws {
		XCTAssertThrowsError(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: false
			).version
		) {
			XCTAssertEqual($0 as? ParserError, ParserError.noFormattedCommits)
		}
	}

	func testParseNextVersionNoTagsNoLogsStrict() throws {
		XCTAssertThrowsError(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: true
			).version
		) {
			XCTAssertEqual($0 as? ParserError, ParserError.noFormattedCommits)
		}
	}

	func testParseNextVersionNoTagsSingleFeatCommit() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeFeature
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: false
			).version,
			SemanticVersion(major: 0, minor: 1, patch: 0)
		)
	}

	func testParseNextVersionNoTagsSingleFeatCommitStrict() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeFeature
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: true
			).version,
			SemanticVersion(major: 0, minor: 1, patch: 0)
		)
	}

	func testParseNextVersionNoTagsSingleFixCommit() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeBugfix
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: false
			).version,
			SemanticVersion(major: 0, minor: 1, patch: 0)
		)
	}

	func testParseNextVersionNoTagsSingleFixCommitStrict() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeBugfix
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: true
			).version,
			SemanticVersion(major: 0, minor: 0, patch: 1)
		)
	}

	func testParseNextVersionNoTagsSingleHotfixCommit() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeHotfix
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: false
			).version,
			SemanticVersion(major: 0, minor: 0, patch: 1)
		)
	}

	func testParseNextVersionNoTagsSingleHotfixCommitStrict() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeHotfix
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: true
			).version,
			SemanticVersion(major: 0, minor: 0, patch: 0)
		)
	}

	func testParseNextVersionNoTagsSingleFeatBreakingChangeCommit() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeFeatureBreakingChange
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: false
			).version,
			SemanticVersion(major: 1, minor: 0, patch: 0)
		)
	}

	func testParseNextVersionNoTagsSingleFeatBreakingChangeCommitStrict() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeFeatureBreakingChange
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: true
			).version,
			SemanticVersion(major: 1, minor: 0, patch: 0)
		)
	}

	func testParseNextVersionNoTagsSingleFixBreakingChangeCommit() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeBugfixBreakingChange
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: false
			).version,
			SemanticVersion(major: 1, minor: 0, patch: 0)
		)
	}

	func testParseNextVersionNoTagsSingleFixBreakingChangeCommitStrict() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeBugfixBreakingChange
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: true
			).version,
			SemanticVersion(major: 1, minor: 0, patch: 0)
		)
	}

	func testParseNextVersionNoTagsSingleHotfixBreakingChangeCommit() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						GitCommit(
							hash: "abcdef",
							subject: "hotfix!: My bugfix")
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: false
			).version,
			SemanticVersion(major: 1, minor: 0, patch: 0)
		)
	}

	func testParseNextVersionNoTagsSingleHotfixBreakingChangeCommitStrict() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						GitCommit(
							hash: "abcdef",
							subject: "hotfix!: My bugfix")
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: false
			).version,
			SemanticVersion(major: 1, minor: 0, patch: 0)
		)
	}

	func testParseNextVersionNoTagsBreakingChangeMultipleCommits() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeBugfixBreakingChange,
						.mockAwesomeChore,
						.mockAwesomeFeature,
						.mockAwesomeHotfix,
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: false
			).version,
			SemanticVersion(major: 1, minor: 0, patch: 0)
		)
	}

	func testParseNextVersionNoTagsBreakingChangeMultipleCommitsStrict() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeBugfixBreakingChange,
						.mockAwesomeChore,
						.mockAwesomeFeature,
						.mockAwesomeHotfix,
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: true
			).version,
			SemanticVersion(major: 1, minor: 0, patch: 0)
		)
	}

	func testParseNextVersionNoTagsFeatMultipleCommits() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeChore,
						.mockAwesomeFeature,
						.mockAwesomeHotfix,
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: false
			).version,
			SemanticVersion(major: 0, minor: 1, patch: 0)
		)
	}

	func testParseNextVersionNoTagsFeatMultipleCommitsStrict() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeChore,
						.mockAwesomeFeature,
						.mockAwesomeHotfix,
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: true
			).version,
			SemanticVersion(major: 0, minor: 1, patch: 0)
		)
	}

	func testParseNextVersionNoTagsFixMultipleCommits() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeChore,
						.mockAwesomeBugfix,
						.mockAwesomeHotfix,
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: false
			).version,
			SemanticVersion(major: 0, minor: 1, patch: 0)
		)
	}

	func testParseNextVersionNoTagsFixMultipleCommitsStrict() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeChore,
						.mockAwesomeBugfix,
						.mockAwesomeHotfix,
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: true
			).version,
			SemanticVersion(major: 0, minor: 0, patch: 1)
		)
	}

	func testParseNextVersionNoTagsHotfixMultipleCommits() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeChore,
						.mockAwesomeHotfix,
						.mockAwesomeHotfix,
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: false
			).version,
			SemanticVersion(major: 0, minor: 0, patch: 1)
		)
	}

	func testParseNextVersionNoTagsHotfixMultipleCommitsStrict() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ in
					[
						.mockAwesomeChore,
						.mockAwesomeHotfix,
						.mockAwesomeHotfix,
					]
				} tag: {
					[]
				},
				strictInterpretationOfConventionalCommits: true
			).version,
			SemanticVersion(major: 0, minor: 0, patch: 0)
		)
	}
}
