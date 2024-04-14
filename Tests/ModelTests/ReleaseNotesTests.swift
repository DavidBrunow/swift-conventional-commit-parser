import XCTest

@testable import Model

class ReleaseNotesTests: XCTestCase {
  func testReleaseNotes() {
    XCTAssertEqual(
      ReleaseNotes(
        version: SemanticVersion(major: 1, minor: 0, patch: 0),
        conventionalCommits: [
          ConventionalCommit(commit: .mockAwesomeChore)!,
          ConventionalCommit(commit: .mockAwesomeFeature)!,
        ]
      ).markdown,
      """
      ## 1.0.0

      ### Chores
      * Awesome chore (abcdef)

      ### Features
      * Awesome feature (abcdef)
      """
    )
  }

  func testReleaseNotesWithQuoteInCommit() throws {
    let json = ReleaseNotes(
      version: SemanticVersion(major: 1, minor: 0, patch: 0),
      conventionalCommits: [
        ConventionalCommit(
          commit: GitCommit(
            """
            abcdef \(GitCommit.Constants.fieldSeparator) chore: Change the "total" field
            """
          )!
        )!,
        ConventionalCommit(commit: .mockAwesomeFeature)!,
      ]
    ).json
    let expected = """
      {
        "version" : "1.0.0",
        "containsBreakingChange" : false,
        "releaseNotes" : "## 1.0.0\\n\\n### Chores\\n* Change the \\\"total\\\" field (abcdef)\\n\\n### Features\\n* Awesome feature (abcdef)"
      }
      """

    XCTAssertEqual(
      json,
      expected
    )
    let jsonObject = try? JSONSerialization.jsonObject(with: expected.data(using: .utf8)!, options: [])
    XCTAssertTrue(jsonObject != nil)
    XCTAssertEqual(
      String(
        data: try! JSONSerialization.data(withJSONObject: jsonObject as Any, options: [.prettyPrinted]),
        encoding: .utf8
      ),
      expected
    )
  }
}
