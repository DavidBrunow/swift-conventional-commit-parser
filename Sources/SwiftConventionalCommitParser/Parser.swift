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
		targetBranch: String? = nil,
		hideCommitHashes: Bool = false,
		strictInterpretationOfConventionalCommits: Bool,
		noFormattedCommitsErrorMessage: String = "No formatted commits"
	) throws -> ReleaseNotes {
		let tags = gitClient.tag()

		let semanticVersions = tags.compactMap { SemanticVersion(tag: $0) }.sorted {
			$0 < $1
		}

		if let targetBranch {
			let commitsSinceLastBranch = gitClient.commitsSinceBranch(
				targetBranch: targetBranch)
			let conventionalCommitsSinceLastBranch = commitsSinceLastBranch.compactMap {
				ConventionalCommit(commit: $0)
			}
			//      print("Conventional commits since last branch: \(conventionalCommitsSinceLastBranch)")
			if conventionalCommitsSinceLastBranch.count == 0 {
				throw ParserError.noFormattedCommits(noFormattedCommitsErrorMessage)
			}
		}

		let commitsSinceLastTag = gitClient.commitsSinceTag(semanticVersions.last?.tag)

		let conventionalCommits = commitsSinceLastTag.compactMap {
			ConventionalCommit(commit: $0)
		}

		guard conventionalCommits.count > 0 else {
			throw ParserError.noFormattedCommits(noFormattedCommitsErrorMessage)
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
			bumpType: bumpType,
			conventionalCommits: conventionalCommits,
			hideCommitHashes: hideCommitHashes
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
