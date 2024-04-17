import ArgumentParser
import Dependencies
import GitClient
import SwiftConventionalCommitParser

struct ParseCommand: AsyncParsableCommand {
	func run() async throws {
		try withDependencies {
			$0[GitClient.self] = .liveValue
		} operation: {
			let releaseNotes = try Parser().releaseNotes()

			print("\(releaseNotes.json)")
		}
	}
}
