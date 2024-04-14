import Model
import XCTest

class GitCommitTests: XCTestCase {
  func testInitialization() {
    XCTAssertNil(GitCommit(""))
    XCTAssertNil(GitCommit("abcdef feat: My awesome feature"))
    XCTAssertEqual(
      GitCommit("abcdef \(GitCommit.Constants.fieldSeparator) feat: My awesome feature"),
      GitCommit(hash: "abcdef", subject: "feat: My awesome feature")
    )
    XCTAssertEqual(
      GitCommit("abcdef \(GitCommit.Constants.fieldSeparator) feat: My awesome feature \(GitCommit.Constants.fieldSeparator)"),
      GitCommit(hash: "abcdef", subject: "feat: My awesome feature", body: "")
    )
    XCTAssertEqual(
      GitCommit("abcdef \(GitCommit.Constants.fieldSeparator) feat: My awesome feature \(GitCommit.Constants.fieldSeparator) Some more description about the awesome feature"),
      GitCommit(hash: "abcdef", subject: "feat: My awesome feature", body: "Some more description about the awesome feature")
    )
    XCTAssertNil(
      GitCommit("abcdef \(GitCommit.Constants.fieldSeparator) feat: My awesome feature \(GitCommit.Constants.fieldSeparator) Some more description about the awesome feature \(GitCommit.Constants.fieldSeparator)")
    )
  }
}
