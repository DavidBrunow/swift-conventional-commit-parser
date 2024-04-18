import Foundation

/// A semantic version as defined by https://semver.org.
public struct SemanticVersion: Equatable {
	/// Different ways that one version can be incremented to another version.
	public enum BumpType {
		/// A semantic version bump of the first number.
		case major
		/// A semantic version bump of the second number.
		case minor
		/// A semantic version bump of the third number.
		case patch
		/// No change to the semantic version.
		case none
	}

	let major: Int
	let minor: Int
	let patch: Int
	let prerelease: String?

	/// Initializes a `SemanticVersion`. This initializer is generally used in situations like testing or
	/// previews, where you have a specific semantic version you want to use without mucking around with
	/// parsing.
	/// - Parameters:
	///   - major: The first number in the semantic version.
	///   - minor: The second number in the semantic version.
	///   - patch: The third number in the semantic version.
	///   - prerelease: Prerelease information that is in the version.
	@_disfavoredOverload
	public init(
		major: Int,
		minor: Int,
		patch: Int,
		prerelease: String? = nil
	) {
		self.major = major
		self.minor = minor
		self.patch = patch
		self.prerelease = prerelease
	}

	/// Initializes a `SemanticVersion` from a git tag. Initialization fails if a semantic version cannot be
	/// parsed from the tag.
	/// - Parameter tag: A tag returned from git. Must be in a format that meets the semver standard
	/// in order to parse successfully.
	public init?(tag: String) {
		let tagWithoutPrerelease: String

		if let firstHyphenIndex = tag.firstIndex(of: "-") {
			self.prerelease = String(
				tag.suffix(from: tag.index(after: firstHyphenIndex)))
			tagWithoutPrerelease = String(tag.prefix(upTo: firstHyphenIndex))
		} else {
			self.prerelease = nil
			tagWithoutPrerelease = tag
		}

		let parts = tagWithoutPrerelease.split(separator: ".")
		guard parts.count == 3 else {
			return nil
		}

		guard
			let major = Int(
				parts[0].replacingOccurrences(
					of: "v",
					with: ""
				)
			)
		else {
			return nil
		}
		guard
			let minor = Int(
				parts[1]
			)
		else {
			return nil
		}

		guard
			let patch = Int(
				parts[2]
			)
		else {
			return nil
		}

		self.major = major
		self.minor = minor
		self.patch = patch
	}

	/// The string representation of this semantic version.
	public var tag: String {
		// swiftlint:disable:next force_unwrapping
		"\(major).\(minor).\(patch)\(prerelease != nil ? "-\(prerelease!)" : "")"
	}

	/// Increases a semantic version by the provided bump type.
	/// - Parameter bumpType: A `BumpType` that indicates how a semantic version should be
	/// increased.
	/// - Returns: A new instance of `SemanticVersion` with the version bump applied.
	public func bump(_ bumpType: BumpType) -> Self {
		switch bumpType {
		case .major:
			return SemanticVersion(
				major: self.major + 1,
				minor: 0,
				patch: 0
			)
		case .minor:
			return SemanticVersion(
				major: self.major,
				minor: self.minor + 1,
				patch: 0
			)
		case .none:
			return self
		case .patch:
			return SemanticVersion(
				major: self.major,
				minor: self.minor,
				patch: self.patch + 1
			)
		}
	}
}

extension SemanticVersion: Comparable {
	/// No overview available.
	public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
		if lhs.major != rhs.major {
			return lhs.major < rhs.major
		} else if lhs.minor != rhs.minor {
			return lhs.minor < rhs.minor
		} else if lhs.patch != rhs.patch {
			return lhs.patch < rhs.patch
		} else {
			switch lhs.prerelease {
			case .none:
				if rhs.prerelease != nil {
					return false
				}
			case let .some(lhsPrerelease):
				// Example: 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0.
				if let rhsPrerelease = rhs.prerelease {
					return lhsPrerelease < rhsPrerelease
				} else {
					return true
				}
			}
		}

		return false
	}
}
