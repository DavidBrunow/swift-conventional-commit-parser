/// Represents a git commit.
///
/// > Note: This is only a partial implementation of a git commit, limited to
/// the things needed for parsing conventional commits.
public struct GitCommit: Equatable {
	/// Constants that are used in parsing git commits.
	public enum ParsingConstants {
		/// Separator used for parsing the different fields in a git commit.
		public static let fieldSeparator = "@-@-@-@-@"
	}

	/// The git commit's hash.
	public let hash: String
	/// The git commit's subject.
	public let subject: String
	/// The git commit's body.
	public let body: String?

	/// Initializes a `GitCommit`. This initializer is generally used in
	/// situations like testing or previews, where you have a specific
	/// conventional commit you want to use without mucking around with parsing.
	/// - Parameters:
	///   - hash: The git commit's hash.
	///   - subject: The git commit's subject.
	///   - body: The git commit's body.
	public init(hash: String, subject: String, body: String? = nil) {
		self.hash = hash
		self.subject = subject
		self.body = body
	}

	/// Parses a specially formatted git commit produced by git log.
	/// - Parameter rawString: A string produces by the `git log` command using this format:
	/// `--pretty="%h @-@-@-@-@ %s @-@-@-@-@ %b"`
	public init?(_ rawString: String) {
		let components = rawString.components(separatedBy: ParsingConstants.fieldSeparator)
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

		guard components.count >= 2 && components.count < 4 else {
			return nil
		}

		self.hash = components[0]
		self.subject = components[1]

		if components.count == 3 {
			self.body = components[2]
		} else {
			self.body = nil
		}
	}
}

#if DEBUG
	extension GitCommit {
		/// Mock "wip" git commit.
		public static let mockWip = Self(hash: "abcdef", subject: "wip")

		/// Mock git commit that has a colon but does not follow the conventional
		/// commit standard.
		public static let mockNonConventionalCommitWithColon = Self(
			hash: "abcdef",
			subject: "commit author: Smokes"
		)

		/// Mock git commit that is a `feat:` conventional commit.
		public static let mockAwesomeFeature = Self(
			hash: "abcdef",
			subject: "feat: Awesome feature"
		)

		/// Mock git commit that is a `feat!:` conventional commit.
		public static let mockAwesomeFeatureBreakingChange = Self(
			hash: "abcdef",
			subject: "feat!: Awesome feature"
		)

		/// Mock git commit that is a `feat:` conventional commit with "api" scope.
		public static let mockAwesomeFeatureWithApiScope = Self(
			hash: "abcdef",
			subject: "feat(api): Awesome feature"
		)

		/// Mock git commit that is a `fix:` conventional commit.
		public static let mockAwesomeBugfix = Self(
			hash: "abcdef",
			subject: "fix: Awesome bug fix"
		)

		/// Mock git commit that is a `fix!:` conventional commit.
		public static let mockAwesomeBugfixBreakingChange = Self(
			hash: "abcdef",
			subject: "fix!: Awesome bug fix"
		)

		/// Mock git commit that is a `Fix:` conventional commit.
		public static let mockAwesomeBugfixWithDifferentCapitalization = Self(
			hash: "abcdef",
			subject: "Fix: Awesome bug fix"
		)

		/// Mock git commit that is a `chore:` conventional commit.
		public static let mockAwesomeChore = Self(
			hash: "abcdef",
			subject: "chore: Awesome chore"
		)

		/// Mock git commit that is a `hotfix:` conventional commit.
		public static let mockAwesomeHotfix = Self(
			hash: "abcdef",
			subject: "hotfix: Awesome hotfix"
		)

		/// Mock git commit that is a `turtles!:` conventional commit.
		public static let mockUnknownTypeBreakingChange = Self(
			hash: "abcdef",
			subject: "turtles!: Awesome turtles"
		)
	}
#endif
