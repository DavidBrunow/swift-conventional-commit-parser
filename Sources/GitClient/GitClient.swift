import Dependencies
import Model

/// Provides access to `git`.
public struct GitClient {
	/// Returns the results of the `git log` command as an array of `GitCommit` that represent the
	/// commits in a git repository.
	/// - Parameter tag: An optional tag that, when provided, will run the `git log` command from
	/// HEAD to that tag.
	public func log(toTag tag: String?) -> [GitCommit] {
		_log(tag)
	}

	/// Returns the results of the `git tag` command as an array of strings that represent the tags on a
	/// repo.
	public func tag() -> [String] {
		_tag()
	}

	var _log: (String?) -> [GitCommit] = { _ in [] }
	var _tag: () -> [String] = { [] }

	/// Initializes a `GitClient`.
	/// - Parameters:
	///   - log: A closure that takes an optional `String` and returns an array of `GitCommit`.
	///   - tag: A closure that returns an array of `String` representing git tags.
	public init(
		log: @escaping (String?) -> [GitCommit],
		tag: @escaping () -> [String]
	) {
		self._log = log
		self._tag = tag
	}
}

extension GitClient {
	/// A simple, mock `GitClient` with a single commit and multiple tags.
	public static let mock = Self { _ in
		[
			GitCommit(hash: "123456", subject: "feat: Cool feature, bro", body: nil)
		]
	} tag: {
		[
			"1.0.0",
			"1.4.0",
			"1.3.0",
			"1.2.0",
			"1.4.1",
			"1.1.0",
		]
	}

	/// An empty mock `GitClient` with no commits and no tags.
	public static let empty = Self { _ in
		[]
	} tag: {
		[]
	}
}

extension GitClient: DependencyKey {
	/// No overview available.
	public static let testValue: GitClient = .mock
}
