import Model
import XCTest

class SemanticVersionTests: XCTestCase {
	func testInitializingFromTag() {
		XCTAssertNil(SemanticVersion(tag: ""))
		XCTAssertNil(SemanticVersion(tag: "turtles"))
		XCTAssertNil(SemanticVersion(tag: "heros.in.a-half.shell"))
		XCTAssertEqual(
			SemanticVersion(tag: "v1.2.3"),
			SemanticVersion(major: 1, minor: 2, patch: 3)
		)
		XCTAssertEqual(
			SemanticVersion(tag: "1.2.3"),
			SemanticVersion(major: 1, minor: 2, patch: 3)
		)
		XCTAssertEqual(
			SemanticVersion(tag: "v1.2.3-rc1"),
			SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: "rc1")
		)
		XCTAssertEqual(
			SemanticVersion(tag: "v1.2.3-rc1-0.5.1"),
			SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: "rc1-0.5.1")
		)
	}

	func testComparison() {
		let v0dot0dot0 = SemanticVersion(major: 0, minor: 0, patch: 0)
		let v0dot0dot1 = SemanticVersion(major: 0, minor: 0, patch: 1)
		let v0dot1dot0 = SemanticVersion(major: 0, minor: 1, patch: 0)
		let v0dot4dot0 = SemanticVersion(major: 0, minor: 1, patch: 0)
		let v1dot0dot0 = SemanticVersion(major: 1, minor: 0, patch: 0)
		let v2dot0dot0 = SemanticVersion(major: 2, minor: 0, patch: 0)
		let v1dot0dot0Prerelease1 = SemanticVersion(
			major: 1,
			minor: 0,
			patch: 0,
			prerelease: "rc1"
		)
		let v1dot0dot0Prerelease2 = SemanticVersion(
			major: 1,
			minor: 0,
			patch: 0,
			prerelease: "rc1-0.5.1"
		)
		XCTAssertTrue(v0dot0dot0 < v0dot0dot1)
		XCTAssertTrue(v0dot0dot1 < v0dot1dot0)
		XCTAssertTrue(v0dot1dot0 < v1dot0dot0)
		XCTAssertTrue(v1dot0dot0Prerelease1 < v1dot0dot0)
		XCTAssertTrue(v1dot0dot0Prerelease1 < v1dot0dot0Prerelease2)
		XCTAssertTrue(v0dot0dot0 < v2dot0dot0)
		XCTAssertTrue(v0dot0dot1 < v2dot0dot0)
		XCTAssertTrue(v0dot1dot0 < v2dot0dot0)
		XCTAssertTrue(v1dot0dot0 < v2dot0dot0)
		XCTAssertTrue(v0dot4dot0 < v2dot0dot0)
		XCTAssertFalse(v2dot0dot0 < v0dot4dot0)
	}

	func testVersionBumps() {
		let v0dot0dot0 = SemanticVersion(major: 0, minor: 0, patch: 0)
		let v0dot0dot1 = SemanticVersion(major: 0, minor: 0, patch: 1)
		let v0dot1dot0 = SemanticVersion(major: 0, minor: 1, patch: 0)
		let v1dot0dot0 = SemanticVersion(major: 1, minor: 0, patch: 0)

		XCTAssertEqual(v0dot0dot0.bump(.major), v1dot0dot0)
		XCTAssertEqual(v0dot0dot0.bump(.minor), v0dot1dot0)
		XCTAssertEqual(v0dot0dot0.bump(.patch), v0dot0dot1)
	}

	func testTag() {
		let v0dot0dot0 = SemanticVersion(major: 0, minor: 0, patch: 0)
		let v0dot0dot1 = SemanticVersion(major: 0, minor: 0, patch: 1)
		let v0dot1dot0 = SemanticVersion(major: 0, minor: 1, patch: 0)
		let v1dot0dot0 = SemanticVersion(major: 1, minor: 0, patch: 0)
		let v1dot0dot0Prerelease1 = SemanticVersion(
			major: 1,
			minor: 0,
			patch: 0,
			prerelease: "rc1"
		)

		XCTAssertEqual(v0dot0dot0.tag, "0.0.0")
		XCTAssertEqual(v0dot0dot1.tag, "0.0.1")
		XCTAssertEqual(v0dot1dot0.tag, "0.1.0")
		XCTAssertEqual(v1dot0dot0.tag, "1.0.0")
		XCTAssertEqual(v1dot0dot0Prerelease1.tag, "1.0.0-rc1")
	}
}
