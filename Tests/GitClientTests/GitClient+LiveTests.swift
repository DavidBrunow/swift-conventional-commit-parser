import XCTest
import GitClient
import Model
import Foundation

final class GitClientLiveTests: XCTestCase {
	
	// MARK: - GitError.repositoryNotFound Tests
	
	func testRepositoryNotFoundError() throws {
		// Create a temporary directory without .git
		let tempDir = FileManager.default.temporaryDirectory
			.appendingPathComponent("test-no-git-\(UUID().uuidString)")
		
		try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
		defer { try? FileManager.default.removeItem(at: tempDir) }
		
		// Change to the temp directory and test
		let originalDir = FileManager.default.currentDirectoryPath
		FileManager.default.changeCurrentDirectoryPath(tempDir.path)
		defer { FileManager.default.changeCurrentDirectoryPath(originalDir) }
		
		let gitClient = GitClient.liveValue
		
		// Test that all GitClient methods throw repositoryNotFound
		XCTAssertThrowsError(try gitClient.tag()) { error in
			guard let gitError = error as? GitError,
				  case .repositoryNotFound = gitError else {
				XCTFail("Expected GitError.repositoryNotFound, got \(error)")
				return
			}
		}
		
		XCTAssertThrowsError(try gitClient.commitsSinceTag(nil)) { error in
			guard let gitError = error as? GitError,
				  case .repositoryNotFound = gitError else {
				XCTFail("Expected GitError.repositoryNotFound, got \(error)")
				return
			}
		}
		
		XCTAssertThrowsError(try gitClient.commitsSinceBranch(targetBranch: "main")) { error in
			guard let gitError = error as? GitError,
				  case .repositoryNotFound = gitError else {
				XCTFail("Expected GitError.repositoryNotFound, got \(error)")
				return
			}
		}
	}
	
	// MARK: - GitError.gitCommandFailed Tests
	
	func testGitCommandFailedWithInvalidBranch() throws {
		// Create a git repository with a simple commit
		let tempDir = try createTestRepository()
		defer { try? FileManager.default.removeItem(at: tempDir) }
		
		let originalDir = FileManager.default.currentDirectoryPath
		FileManager.default.changeCurrentDirectoryPath(tempDir.path)
		defer { FileManager.default.changeCurrentDirectoryPath(originalDir) }
		
		let gitClient = GitClient.liveValue
		
		// Test with a branch that definitely doesn't exist
		let nonExistentBranch = "nonexistent-branch-\(UUID().uuidString)"
		
		XCTAssertThrowsError(try gitClient.commitsSinceBranch(targetBranch: nonExistentBranch)) { error in
			guard let gitError = error as? GitError,
				  case .gitCommandFailed(let command, let exitCode) = gitError else {
				XCTFail("Expected GitError.gitCommandFailed, got \(error)")
				return
			}
			
			// Verify the command contains the branch name and failed
			XCTAssertTrue(command.contains(nonExistentBranch), "Command should contain branch name: \(command)")
			XCTAssertNotEqual(exitCode, 0, "Exit code should be non-zero for failed command")
		}
	}
	
	func testGitCommandFailedInEmptyRepository() throws {
		// Create an empty git repository (no commits)
		let tempDir = try createEmptyTestRepository()
		defer { try? FileManager.default.removeItem(at: tempDir) }
		
		let originalDir = FileManager.default.currentDirectoryPath
		FileManager.default.changeCurrentDirectoryPath(tempDir.path)
		defer { FileManager.default.changeCurrentDirectoryPath(originalDir) }
		
		let gitClient = GitClient.liveValue
		
		// Empty repository should fail git tag command
		XCTAssertThrowsError(try gitClient.tag()) { error in
			guard let gitError = error as? GitError,
				  case .gitCommandFailed(let command, let exitCode) = gitError else {
				XCTFail("Expected GitError.gitCommandFailed, got \(error)")
				return
			}
			
			XCTAssertEqual(command, "git tag --merged")
			XCTAssertEqual(exitCode, 128) // Git's "fatal" error code for empty repo
		}
	}
}

// MARK: - Test Helpers

extension GitClientLiveTests {
	
	/// Creates a temporary git repository with a simple commit
	private func createTestRepository() throws -> URL {
		let tempDir = FileManager.default.temporaryDirectory
			.appendingPathComponent("test-git-repo-\(UUID().uuidString)")
		
		try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
		
		// Initialize git repository
		try runGitCommand(["init"], in: tempDir)
		
		// Configure git user (required for commits)
		try runGitCommand(["config", "user.name", "Test User"], in: tempDir)
		try runGitCommand(["config", "user.email", "test@example.com"], in: tempDir)
		
		// Create a simple file and commit
		let testFile = tempDir.appendingPathComponent("test.txt")
		try "test content".write(to: testFile, atomically: true, encoding: .utf8)
		
		try runGitCommand(["add", "test.txt"], in: tempDir)
		try runGitCommand(["commit", "-m", "Initial commit"], in: tempDir)
		
		return tempDir
	}
	
	/// Creates a temporary empty git repository (no commits)
	private func createEmptyTestRepository() throws -> URL {
		let tempDir = FileManager.default.temporaryDirectory
			.appendingPathComponent("test-empty-git-repo-\(UUID().uuidString)")
		
		try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
		
		// Initialize git repository but don't add any commits
		try runGitCommand(["init"], in: tempDir)
		
		return tempDir
	}
	
	/// Runs a git command in the specified directory
	private func runGitCommand(_ arguments: [String], in directory: URL) throws {
		let process = Process()
		process.launchPath = "/usr/bin/git"
		process.arguments = arguments
		process.currentDirectoryPath = directory.path
		
		try process.run()
		process.waitUntilExit()
		
		guard process.terminationStatus == 0 else {
			throw TestError.gitCommandFailed(arguments.joined(separator: " "))
		}
	}
	
	private enum TestError: Error {
		case gitCommandFailed(String)
	}
}