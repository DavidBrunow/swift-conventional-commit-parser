import Dependencies
import GitClient
import Model

public struct Parser {
	public static func releaseNotes(
		strictInterpretationOfConventionalCommits: Bool
	) throws -> ReleaseNotes {
		@Dependency(GitClient.self) var gitClient

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
			throw ParserError.noFormattedCommits
		}

		let nextSemanticVersion = lastSemanticVersion.bump(bumpType)

		return ReleaseNotes(
			version: nextSemanticVersion,
			conventionalCommits: conventionalCommits
		)
	}
}

public enum ParserError: Error {
	case noFormattedCommits

	var localizedDescription: String {
		switch self {
		case .noFormattedCommits:
			"No formatted commits"
		}
	}
}
