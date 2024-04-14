import Dependencies
import Foundation
import GitClient
import Model

/// Parses commits provided by a `GitClient`.
public struct Parser {
	/// Generates release notes from commits provided by a `GitClient`.
	/// - Parameter gitClient: A `GitClient` used for interacting with git.
	/// - Parameter strictInterpretationOfConventionalCommits: Whether to follow the Conventional Commit standard strictly or not.
	/// Defaults to false, which makes `fix:` commits minor version bumps and adds the `hotfix:` commit for patch version bumps.
	public static func releaseNotes(
		gitClient: GitClient,
		strictInterpretationOfConventionalCommits: Bool,
		noFormattedCommitsErrorMessage: String = "No formatted commits"
	) throws -> ReleaseNotes {
		let tags = gitClient.tag()

		let semanticVersions = tags.compactMap { SemanticVersion(tag: $0) }.sorted {
			$0 < $1
		}

		let commitsSinceLastTag = gitClient.log(toTag: semanticVersions.last?.tag)

		let conventionalCommits = commitsSinceLastTag.compactMap {
			ConventionalCommit(commit: $0)
		}

		let lastSemanticVersion =
			semanticVersions.last ?? .init(major: 0, minor: 0, patch: 0)

		let bumpType: SemanticVersion.BumpType

		if conventionalCommits.contains(where: { $0.isBreaking }) {
			bumpType = .major
		} else if conventionalCommits.contains(where: {
			$0.type == .known(.feat)
				|| ($0.type == .known(.fix)
					&& strictInterpretationOfConventionalCommits == false)
		}) {
			bumpType = .minor
		} else if conventionalCommits.contains(where: {
			$0.type == .known(.fix)
		}) && strictInterpretationOfConventionalCommits {
			bumpType = .patch
		} else if conventionalCommits.contains(where: { $0.type == .known(.hotfix) })
			&& strictInterpretationOfConventionalCommits == false
		{
			bumpType = .patch
		} else if conventionalCommits.isEmpty == false {
			bumpType = .none
		} else {
			throw ParserError.noFormattedCommits(noFormattedCommitsErrorMessage)
		}

		let nextSemanticVersion = lastSemanticVersion.bump(bumpType)

		return ReleaseNotes(
			version: nextSemanticVersion,
			conventionalCommits: conventionalCommits
		)
	}
}

public enum ParserError: LocalizedError {
	case noFormattedCommits(String)

	/// No overview available.
	public var errorDescription: String? {
		switch self {
		case let .noFormattedCommits(errorMessage):
			return errorMessage
		}
	}
}
