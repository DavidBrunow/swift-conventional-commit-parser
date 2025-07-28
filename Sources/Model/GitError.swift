import Foundation

/// Errors related to git operations.
public enum GitError: ActionableError {
	case repositoryNotFound
	case invalidRepository
	case gitCommandFailed(String, exitCode: Int)

	public var errorDescription: String? {
		switch self {
		case .repositoryNotFound:
			return "No git repository found in current directory"
		case .invalidRepository:
			return "Invalid git repository structure"
		case .gitCommandFailed(let command, let exitCode):
			return "Git command '\(command)' failed with exit code \(exitCode)"
		}
	}

	public var recoverySuggestion: String? {
		switch self {
		case .repositoryNotFound:
			return "Ensure you're running this command from within a git repository"
		case .invalidRepository:
			return
				"Check that the git repository is properly initialized and not corrupted"
		case .gitCommandFailed(let command, _):
			return "Check git status and ensure '\(command)' can be run manually"
		}
	}
}
