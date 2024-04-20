// swift-tools-version:5.9

import Foundation
import PackageDescription

let package = Package(
	name: "swift-conventional-commit-parser",
	platforms: [
		.macOS("12")
	],
	products: [
		.executable(
			name: "swift-conventional-commit-parser",
			targets: ["swift-conventional-commit-parser"]
		),
		.library(
			name: "SwiftConventionalCommitParser",
			targets: ["SwiftConventionalCommitParser"]
		),
		.plugin(
			name: "SwiftFormatLintBuildToolPlugin",
			targets: ["SwiftFormatLintBuildToolPlugin"]
		),
	],
	dependencies: [
		.package(
			url: "https://github.com/apple/swift-argument-parser.git",
			from: "1.2.2"
		),
		.package(
			url: "https://github.com/pointfreeco/swift-dependencies.git",
			from: "1.0.0"
		),
	],
	targets: [
		.plugin(
			name: "SwiftFormatLintBuildToolPlugin",
			capability: .buildTool(),
			dependencies: [
				.product(name: "swift-format", package: "swift-format")
			]
		),
		.target(
			name: "GitClient",
			dependencies: [
				"Model",
				.product(name: "Dependencies", package: "swift-dependencies"),
				.product(name: "DependenciesMacros", package: "swift-dependencies"),
			]
		),
		.testTarget(
			name: "GitClientTests",
			dependencies: [
				"GitClient"
			]
		),
		.target(
			name: "Model",
			dependencies: [
				.product(name: "Dependencies", package: "swift-dependencies")
			]
		),
		.testTarget(
			name: "ModelTests",
			dependencies: [
				"Model"
			]
		),
		.target(
			name: "SwiftConventionalCommitParser",
			dependencies: [
				"GitClient",
				"Model",
			]
		),
		.executableTarget(
			name: "swift-conventional-commit-parser",
			dependencies: [
				"SwiftConventionalCommitParser",
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]
		),
		.testTarget(
			name: "SwiftConventionalCommitParserTests",
			dependencies: [
				"SwiftConventionalCommitParser"
			]
		),
		.testTarget(
			name: "swift-conventional-commit-parserTests",
			dependencies: ["swift-conventional-commit-parser"]
		),
	]
)

let swiftSettings: [SwiftSetting] = [
	// -enable-bare-slash-regex becomes
	.enableUpcomingFeature("BareSlashRegexLiterals"),
	// -warn-concurrency becomes
	.enableUpcomingFeature("StrictConcurrency"),
	.unsafeFlags(
		["-enable-actor-data-race-checks"],
		.when(configuration: .debug)),
]

if ProcessInfo.processInfo.environment["CI"] != "true" {
  package.dependencies += [
    // Local Tooling
    .package(url: "https://github.com/apple/swift-format", from: "510.0.0"),
    .package(url: "https://github.com/realm/SwiftLint", branch: "main"),
  ]
}

for target in package.targets {
	guard target.type != .plugin else { continue }

	if target.plugins == nil {
		target.plugins = []
	}

	if ProcessInfo.processInfo.environment["CI"] != "true" {
		target.plugins! += [.plugin(name: "SwiftFormatLintBuildToolPlugin")]
		target.plugins! += [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
	}

	target.swiftSettings = target.swiftSettings ?? []
	target.swiftSettings?.append(contentsOf: swiftSettings)
}
