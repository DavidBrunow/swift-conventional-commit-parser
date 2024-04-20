import Model
import XCTest

class GitCommitTests: XCTestCase {
	func testInitialization() {
		XCTAssertNil(GitCommit(""))
		XCTAssertNil(GitCommit("abcdef feat: My awesome feature"))
		XCTAssertEqual(
			GitCommit(
				"abcdef \(GitCommit.ParsingConstants.fieldSeparator) feat: My awesome feature"
			),
			GitCommit(hash: "abcdef", subject: "feat: My awesome feature")
		)
		XCTAssertEqual(
			GitCommit(
				"abcdef \(GitCommit.ParsingConstants.fieldSeparator) feat: My awesome feature \(GitCommit.ParsingConstants.fieldSeparator)"
			),
			GitCommit(hash: "abcdef", subject: "feat: My awesome feature", body: "")
		)
		XCTAssertEqual(
			GitCommit(
				"abcdef \(GitCommit.ParsingConstants.fieldSeparator) feat: My awesome feature \(GitCommit.ParsingConstants.fieldSeparator) Some more description about the awesome feature"
			),
			GitCommit(
				hash: "abcdef", subject: "feat: My awesome feature",
				body: "Some more description about the awesome feature")
		)
		XCTAssertNil(
			GitCommit(
				"abcdef \(GitCommit.ParsingConstants.fieldSeparator) feat: My awesome feature \(GitCommit.ParsingConstants.fieldSeparator) Some more description about the awesome feature \(GitCommit.ParsingConstants.fieldSeparator)"
			)
		)
	}
}
