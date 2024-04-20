import Foundation

/// A conventional commit as defined by https://www.conventionalcommits.org/en/v1.0.0/#specification.
public struct ConventionalCommit: Equatable {
	public enum CommitType: Equatable {
		/// Commit types that are known by this tool.
		public enum Known: String {
			case feat
			case fix
			case hotfix

			var friendlyName: String {
				switch self {
				case .feat:
					return "Feature"
				case .fix:
					return "Bug Fix"
				case .hotfix:
					return "Hotfix"
				}
			}
		}

		case known(Known)
		case unknown(String)

		/// A user friendly name for the commit type.
		public var friendlyName: String {
			switch self {
			case let .known(value):
				return value.friendlyName
			case let .unknown(value):
				return value.capitalized
			}
		}
	}

	/// A description of the change that was made in this conventional commit.
	public let description: String

	/// The hash of the git commit used to create this conventional commit.
	public let hash: String

	/// A flag representing whether this conventional commit indicates there is a breaking change.
	public let isBreaking: Bool

	/// The scope of the conventional commit.
	public let scope: String?

	/// The type of conventional commit.
	public let type: CommitType

	/// Initializes a `ConventionalCommit`. This initializer is generally used in situations like testing or
	/// previews, where you have a specific conventional commit you want to use without mucking around
	/// with parsing.
	/// - Parameters:
	///   - description: The description to be used for the conventional commit.
	///   - hash: The hash of the git commit.
	///   - scope: The scope of the conventional commit.
	///   - type: The type of the conventional commit.
	public init(
		description: String,
		hash: String,
		isBreaking: Bool,
		scope: String?,
		type: CommitType
	) {
		self.description = description
		self.hash = hash
		self.isBreaking = isBreaking
		self.scope = scope
		self.type = type
	}

	/// Initializes a `ConventionalCommit` from a `GitCommit`. Initialization will fail if the
	/// `GitCommit` does not meet the conventional commit standard.
	/// - Parameter commit: A `GitCommit` that represent a commit from git.
	public init?(commit: GitCommit) {
		guard let colonIndex = commit.subject.firstIndex(of: ":") else {
			return nil
		}
		let firstInvalidCharacterBeforeColonIndex = commit.subject.firstIndex {
			$0.isLetter == false && $0 != "(" && $0 != ")" && $0 != "!"
		}
		if firstInvalidCharacterBeforeColonIndex ?? commit.subject.endIndex < colonIndex {
			return nil
		}
		let type = commit.subject.prefix(upTo: colonIndex).lowercased()

		let scope: String?

		if let firstOpeningParenIndex = type.firstIndex(of: "("),
			let firstClosingParentIndex = type.firstIndex(of: ")")
		{
			scope = String(type[firstOpeningParenIndex...firstClosingParentIndex])
		} else {
			scope = nil
		}

		let typeWithoutScope = type.replacingOccurrences(of: scope ?? "", with: "")

		switch typeWithoutScope {
		case "feat":
			self.type = .known(.feat)
		case "feat!":
			self.type = .known(.feat)
		case "fix":
			self.type = .known(.fix)
		case "fix!":
			self.type = .known(.fix)
		case "hotfix":
			self.type = .known(.hotfix)
		default:
			self.type = .unknown(
				typeWithoutScope.replacingOccurrences(of: "!", with: ""))
		}

		if commit.body?.contains("BREAKING CHANGE:") == true
			|| commit.body?.contains("BREAKING-CHANGE:") == true
			|| typeWithoutScope.suffix(1) == "!"
		{
			self.isBreaking = true
		} else {
			self.isBreaking = false
		}

		self.description = String(
			commit.subject.suffix(from: commit.subject.index(after: colonIndex))
		).trimmingCharacters(in: .whitespacesAndNewlines)
		self.hash = commit.hash
		self.scope = scope?
			.replacingOccurrences(of: "(", with: "")
			.replacingOccurrences(of: ")", with: "")
	}
}
