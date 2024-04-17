import Model
import XCTest

class ConventionalCommitTests: XCTestCase {
	func testInitialization() {
		XCTAssertNil(ConventionalCommit(commit: .mockWip))
		XCTAssertNil(ConventionalCommit(commit: .mockNonConventionalCommitWithColon))
		XCTAssertEqual(
			ConventionalCommit(commit: .mockAwesomeFeature),
			ConventionalCommit(
				description: "Awesome feature",
				hash: "abcdef",
				scope: nil,
				type: .known(.feat)
			)
		)

		XCTAssertEqual(
			ConventionalCommit(commit: .mockAwesomeFeatureWithApiScope),
			ConventionalCommit(
				description: "Awesome feature",
				hash: "abcdef",
				scope: "api",
				type: .known(.feat)
			)
		)

		XCTAssertEqual(
			ConventionalCommit(commit: .mockAwesomeBugfix),
			ConventionalCommit(
				description: "Awesome bugfix",
				hash: "abcdef",
				scope: nil,
				type: .known(.fix)
			)
		)

		XCTAssertEqual(
			ConventionalCommit(commit: .mockAwesomeBugfixWithDifferentCapitalization),
			ConventionalCommit(
				description: "Awesome bugfix",
				hash: "abcdef",
				scope: nil,
				type: .known(.fix)
			)
		)

		XCTAssertEqual(
			ConventionalCommit(commit: .mockAwesomeChore),
			ConventionalCommit(
				description: "Awesome chore",
				hash: "abcdef",
				scope: nil,
				type: .unknown("chore")
			)
		)

		XCTAssertEqual(
			ConventionalCommit(commit: .mockAwesomeFeatureBreakingChange),
			ConventionalCommit(
				description: "Awesome feature",
				hash: "abcdef",
				scope: nil,
				type: .known(.breakingFeat)
			)
		)

		XCTAssertEqual(
			ConventionalCommit(commit: .mockAwesomeBugfixBreakingChange),
			ConventionalCommit(
				description: "Awesome bugfix",
				hash: "abcdef",
				scope: nil,
				type: .known(.breakingFix)
			)
		)
	}

	func testFriendlyNamesForTypes() {
		XCTAssertEqual(
			ConventionalCommit(commit: .mockAwesomeFeatureBreakingChange)?.type
				.friendlyName,
			"Breaking Change Feature"
		)
		XCTAssertEqual(
			ConventionalCommit(commit: .mockAwesomeBugfixBreakingChange)?.type
				.friendlyName,
			"Breaking Change Bug Fix"
		)
		XCTAssertEqual(
			ConventionalCommit(commit: .mockAwesomeFeature)?.type.friendlyName,
			"Feature"
		)
		XCTAssertEqual(
			ConventionalCommit(commit: .mockAwesomeBugfix)?.type.friendlyName,
			"Bug Fix"
		)
		XCTAssertEqual(
			ConventionalCommit(commit: .mockAwesomeHotfix)?.type.friendlyName,
			"Hotfix"
		)
		XCTAssertEqual(
			ConventionalCommit(commit: .mockAwesomeChore)?.type.friendlyName,
			"Chore"
		)
	}
}
