import Foundation
import PackagePlugin

@main
struct SwiftFormatLintBuildToolPlugin: BuildToolPlugin {
	func createBuildCommands(
		context: PluginContext,
		target: Target
	) async throws -> [Command] {
		let swiftFiles = (target as? SourceModuleTarget).flatMap(swiftFiles) ?? []
		guard !swiftFiles.isEmpty else {
			return []
		}

		let arguments: [String] = [
			"lint",
			"-r",
		]
		return [
			.buildCommand(
				displayName: "swift-format",
				executable: try context.tool(named: "swift-format").path,
				arguments: arguments + swiftFiles.map(\.string)
			)
		]
	}

	/// Collects the paths of the Swift files to be linted.
	private func swiftFiles(target: SourceModuleTarget) -> [Path] {
		target
			.sourceFiles(withSuffix: "swift")
			.map(\.path)
	}
}
