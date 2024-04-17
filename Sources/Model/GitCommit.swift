public struct GitCommit: Equatable {
	public enum Constants {
		public static let fieldSeparator = "@-@-@-@-@"
	}

	public let hash: String
	public let subject: String
	public let body: String?

	public init(hash: String, subject: String, body: String? = nil) {
		self.hash = hash
		self.subject = subject
		self.body = body
	}

	public init?(_ rawString: String) {
		let components = rawString.components(separatedBy: Constants.fieldSeparator)
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
		public static let mockWip = Self(hash: "abcdef", subject: "wip")

		public static let mockNonConventionalCommitWithColon = Self(
			hash: "abcdef",
			subject: "commit author: Smokes"
		)

		public static let mockAwesomeFeature = Self(
			hash: "abcdef",
			subject: "feat: Awesome feature"
		)

		public static let mockAwesomeFeatureBreakingChange = Self(
			hash: "abcdef",
			subject: "feat!: Awesome feature"
		)

		public static let mockAwesomeFeatureWithApiScope = Self(
			hash: "abcdef",
			subject: "feat(api): Awesome feature"
		)

		public static let mockAwesomeBugfix = Self(
			hash: "abcdef",
			subject: "fix: Awesome bugfix"
		)

		public static let mockAwesomeBugfixBreakingChange = Self(
			hash: "abcdef",
			subject: "fix!: Awesome bugfix"
		)

		public static let mockAwesomeBugfixWithDifferentCapitalization = Self(
			hash: "abcdef",
			subject: "Fix: Awesome bugfix"
		)

		public static let mockAwesomeChore = Self(
			hash: "abcdef",
			subject: "chore: Awesome chore"
		)

		public static let mockAwesomeHotfix = Self(
			hash: "abcdef",
			subject: "hotfix: Awesome hotfix"
		)
	}
#endif
