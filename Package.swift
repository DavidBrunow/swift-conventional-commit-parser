// swift-tools-version:5.9

import Foundation
import PackageDescription

let package = Package(
  name: "swift-format",
  platforms: [
    .macOS("10.15")
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
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    ),
    .testTarget(
      name: "SwiftConventionalCommitParserTests",
      dependencies: [
        "SwiftConventionalCommitParser",
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
    .unsafeFlags(["-enable-actor-data-race-checks"],
        .when(configuration: .debug)),
]

for target in package.targets {
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(contentsOf: swiftSettings)
}
