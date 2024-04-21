import Dependencies
import Foundation

/// Information related to release notes.
public struct ReleaseNotes {
	/// The semantic version for the release notes.
	public let version: SemanticVersion
	let conventionalCommits: [ConventionalCommit]

	@Dependency(\.date.now) var date

	var containsBreakingChange: Bool {
		conventionalCommits.contains { $0.isBreaking }
	}

	/// Initializes a `ReleaseNotes`.
	/// - Parameters:
	///   - version: The semantic version for the release notes.
	///   - conventionalCommits: The conventional commits that need to be
	///   described in the release notes.
	public init(
		version: SemanticVersion,
		conventionalCommits: [ConventionalCommit]
	) {
		self.version = version
		self.conventionalCommits = conventionalCommits
	}

	var markdown: String {
		var groupedCommits: [String: [ConventionalCommit]] = [:]
		for conventionalCommit in conventionalCommits {
			if groupedCommits[conventionalCommit.type.friendlyName] == nil {
				groupedCommits[conventionalCommit.type.friendlyName] = []
			}
			groupedCommits[conventionalCommit.type.friendlyName]?.append(
				conventionalCommit)
		}

		let notes = groupedCommits.keys.sorted { lhs, rhs in
			if lhs.lowercased().contains("feature") {
				return true
			} else if rhs.lowercased().contains("feature") {
				return false
			} else if lhs.lowercased().contains("bug fix") {
				return true
			} else if rhs.lowercased().contains("bug fix") {
				return false
			} else if lhs.lowercased().contains("hotfix") {
				return true
			} else if rhs.lowercased().contains("hotfix") {
				return false
			}

			return lhs < rhs
		}.map {
			"### \($0.englishPluralized)\n"
				+ (groupedCommits[$0] ?? []).map {
					"* \($0.isBreaking ? "[**BREAKING CHANGE**] " : "")\($0.description) (\($0.hash))"
				}.joined(separator: "\n")
		}

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

		return """
			## [\(version.tag)] - \(dateFormatter.string(from: date))\n
			\(notes.joined(separator: "\n\n").replacingOccurrences(of: "\"", with: "\\\""))
			"""
	}

	/// JSON that represents release notes, including the version, whether it
	/// contains breaking changes, and release notes in Markdown. Here is an
	/// example:
	/// ```json
	/// {
	///   "version" : "1.2.0",
	///   "containsBreakingChange" : false,
	///   "releaseNotes" : "## [1.2.0] - 2024-04-19\\n\\n### Features\\n* Awesome feature (abcdef)\\n\\n### Chores\\n* Change the \\\"total\\\" field (abcdef)"
	/// }
	/// ```
	public var json: String {
		"""
		{
		  "version" : "\(version.tag)",
		  "containsBreakingChange" : \(containsBreakingChange),
		  "releaseNotes" : "\(markdown.replacingOccurrences(of: "\n", with: "\\n"))"
		}
		"""
	}
}

extension String {
	fileprivate var englishPluralized: Self {
		if self.last?.needsEBeforeSInEnglish == true {
			return "\(self)es"
		} else if self.last?.needsNoPluralizationInEnglish == true {
			return self
		}
		return "\(self)s"
	}
}

extension Character {
	fileprivate var needsEBeforeSInEnglish: Bool {
		self == "x"
	}

	fileprivate var needsNoPluralizationInEnglish: Bool {
		self == "s"
	}
}
