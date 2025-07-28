import GitClient
import Model
import SwiftConventionalCommitParser
import XCTest

class ParserTests: XCTestCase {
	func testParseNextVersionNoTagsNoLogs() throws {
		XCTAssertThrowsError(
			try Parser.releaseNotes(
				gitClient: GitClient { _ throws in
					[]
				} tag: { () throws in
					[]
				},
				strictInterpretationOfConventionalCommits: false
			).version
		) {
			XCTAssertEqual(
				($0 as? LocalizedError)?.errorDescription, "No formatted commits"
			)
		}
	}

	func testParseNextVersionNoTagsNoLogsStrict() throws {
		XCTAssertThrowsError(
			try Parser.releaseNotes(
				gitClient: GitClient { _ throws in
					[]
				} tag: { () throws in
					[]
				},
				strictInterpretationOfConventionalCommits: true
			).version
		) {
			XCTAssertEqual(
				($0 as? LocalizedError)?.errorDescription, "No formatted commits"
			)
		}
	}

	func testParseNextVersionNoTagsNoLogsPullRequest() throws {
		XCTAssertThrowsError(
			try Parser.releaseNotes(
				gitClient: GitClient { _ throws in
					[]
				} tag: { () throws in
					[]
				},
				targetBranch: "main",
				strictInterpretationOfConventionalCommits: false
			).version
		) {
			XCTAssertEqual(
				($0 as? LocalizedError)?.errorDescription, "No formatted commits"
			)
		}
	}

	func testParseNextVersionNoTagsNoLogsStrictPullRequest() throws {
		XCTAssertThrowsError(
			try Parser.releaseNotes(
				gitClient: GitClient { _ throws in
					[]
				} tag: { () throws in
					[]
				},
				targetBranch: "main",
				strictInterpretationOfConventionalCommits: true
			).version
		) {
			XCTAssertEqual(
				($0 as? LocalizedError)?.errorDescription, "No formatted commits"
			)
		}
	}

	func testParseNextVersionNoTagsNoLogsOnBranchPullRequest() throws {
		XCTAssertThrowsError(
			try Parser.releaseNotes(
				gitClient: GitClient { logType throws in
					switch logType {
					case .branch:
						return []
					case .tag:
						return [
							.mockAwesomeChore
						]
					}
				} tag: { () throws in
					[]
				},
				targetBranch: "main",
				strictInterpretationOfConventionalCommits: false
			).version
		) {
			XCTAssertEqual(
				($0 as? LocalizedError)?.errorDescription, "No formatted commits"
			)
		}
	}

	func testParseNextVersionNoTagsNoLogsOnBranchStrictPullRequest() throws {
		XCTAssertThrowsError(
			try Parser.releaseNotes(
				gitClient: GitClient { logType throws in
					switch logType {
					case .branch:
						return []
					case .tag:
						return [
							.mockAwesomeChore
						]
					}
				} tag: { () throws in
					[]
				},
				targetBranch: "main",
				strictInterpretationOfConventionalCommits: true
			).version
		) {
			XCTAssertEqual(
				($0 as? LocalizedError)?.errorDescription, "No formatted commits"
			)
		}
	}

	func testParseNextVersionNoTagsSingleFeatCommit() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeFeature
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeFeature
					]
				} tag: { () throws in
					[]
				},
				strictInterpretationOfConventionalCommits: true
			).version,
			SemanticVersion(major: 0, minor: 1, patch: 0)
		)
	}

	func testParseNextVersionNoTagsSingleFeatCommitPullRequest() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeFeature
					]
				} tag: { () throws in
					[]
				},
				targetBranch: "main",
				strictInterpretationOfConventionalCommits: false
			).version,
			SemanticVersion(major: 0, minor: 1, patch: 0)
		)
	}

	func testParseNextVersionNoTagsSingleFeatCommitStrictPullRequest() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeFeature
					]
				} tag: { () throws in
					[]
				},
				targetBranch: "main",
				strictInterpretationOfConventionalCommits: true
			).version,
			SemanticVersion(major: 0, minor: 1, patch: 0)
		)
	}

	func testParseNextVersionNoTagsSingleFixCommit() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeBugfix
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeBugfix
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeHotfix
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeHotfix
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeFeatureBreakingChange
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeFeatureBreakingChange
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeBugfixBreakingChange
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeBugfixBreakingChange
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						GitCommit(
							hash: "abcdef",
							subject: "hotfix!: My bugfix")
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						GitCommit(
							hash: "abcdef",
							subject: "hotfix!: My bugfix")
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeBugfixBreakingChange,
						.mockAwesomeChore,
						.mockAwesomeFeature,
						.mockAwesomeHotfix,
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeBugfixBreakingChange,
						.mockAwesomeChore,
						.mockAwesomeFeature,
						.mockAwesomeHotfix,
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeChore,
						.mockAwesomeFeature,
						.mockAwesomeHotfix,
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeChore,
						.mockAwesomeFeature,
						.mockAwesomeHotfix,
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeChore,
						.mockAwesomeBugfix,
						.mockAwesomeHotfix,
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeChore,
						.mockAwesomeBugfix,
						.mockAwesomeHotfix,
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeChore,
						.mockAwesomeHotfix,
						.mockAwesomeHotfix,
					]
				} tag: { () throws in
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
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeChore,
						.mockAwesomeHotfix,
						.mockAwesomeHotfix,
					]
				} tag: { () throws in
					[]
				},
				strictInterpretationOfConventionalCommits: true
			).version,
			SemanticVersion(major: 0, minor: 0, patch: 0)
		)
	}

	func testParseNextVersionWithTags() throws {
		XCTAssertEqual(
			try Parser.releaseNotes(
				gitClient: GitClient { _ throws in
					[
						.mockAwesomeChore,
						.mockAwesomeBugfix,
					]
				} tag: { () throws in
					[
						"1.0.0",
						"1.2.0",
						"0.6.0",
					]
				},
				strictInterpretationOfConventionalCommits: false
			).version,
			SemanticVersion(major: 1, minor: 3, patch: 0)
		)
	}
}
