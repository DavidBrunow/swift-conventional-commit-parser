import Dependencies
import Model

/// Provides access to `git`.
public struct GitClient {
	public enum LogType {
		case branch(String)
		case tag(String?)
	}

	/// Returns the results of the `git log` command as an array of `GitCommit` that represent the
	/// commits in a git repository.
	/// - Parameter targetBranch: The target branch to compare against.
	/// - Throws: GitError if git operations fail.
	public func commitsSinceBranch(targetBranch: String) throws -> [GitCommit] {
		try _log(.branch(targetBranch))
	}

	/// Returns the results of the `git log` command as an array of `GitCommit` that represent the
	/// commits in a git repository.
	/// - Parameter tag: An optional tag that, when provided, will run the `git log` command from
	/// HEAD to that tag.
	/// - Throws: GitError if git operations fail.
	public func commitsSinceTag(_ tag: String?) throws -> [GitCommit] {
		try _log(.tag(tag))
	}

	/// Returns the results of the `git tag` command as an array of strings that represent the tags on a
	/// repo.
	/// - Throws: GitError if git operations fail.
	public func tag() throws -> [String] {
		try _tag()
	}

	var _log: (LogType) throws -> [GitCommit] = { _ in [] }
	var _tag: () throws -> [String] = { [] }

	/// Initializes a `GitClient`.
	/// - Parameters:
	///   - log: A closure that takes a LogType and returns an array of `GitCommit`.
	///   - tag: A closure that returns an array of `String` representing git tags.
	public init(
		log: @escaping (LogType) throws -> [GitCommit],
		tag: @escaping () throws -> [String]
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
