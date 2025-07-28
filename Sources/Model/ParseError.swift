import Foundation

/// Errors related to parsing conventional commits and semantic versions.
public enum ParseError: ActionableError {
	case noFormattedCommits(String)

	public var errorDescription: String? {
		switch self {
		case .noFormattedCommits(let message):
			return message
		}
	}

	public var recoverySuggestion: String? {
		switch self {
		case .noFormattedCommits:
			return "Ensure at least one commit follows conventional commit format"
		}
	}
}
