import Foundation

/// https://semver.org
public struct SemanticVersion: Equatable {
	public enum BumpType {
		case major
		case minor
		case patch
		case none
	}

	let major: Int
	let minor: Int
	let patch: Int
	let prerelease: String?

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

	public var tag: String {
		// swiftlint:disable:next force_unwrapping
		"\(major).\(minor).\(patch)\(prerelease != nil ? "-\(prerelease!)" : "")"
	}

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
