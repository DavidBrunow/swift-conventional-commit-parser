import Foundation

/// Protocol for errors that provide actionable recovery suggestions to users.
///
/// This protocol extends `LocalizedError` to ensure all application errors
/// provide both a user-friendly description and actionable recovery guidance.
public protocol ActionableError: LocalizedError {
	/// A localized message providing guidance on how to recover from the error.
	/// 
	/// Should provide specific, actionable steps the user can take to resolve
	/// the issue, such as checking file permissions, correcting command syntax,
	/// or linking to relevant documentation.
	var recoverySuggestion: String? { get }
}