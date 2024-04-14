import Dependencies
import DependenciesMacros
import Model

@DependencyClient
public struct GitClient {
  public var log: (String?) -> [GitCommit] = { _ in [] }
  public var tag: () -> [String] = { [] }
}

extension GitClient {
  public static let mock = Self { _ in
    [
      GitCommit(hash: "123456", subject: "feat: Cool feature, bro", body: nil)
    ]
  } tag: {
    [
      "1.0.0",
      "1.4.0",
      "1.3.0",
      "1.2.0",
      "1.4.1",
      "1.1.0",
    ]
  }

  public static let empty = Self { _ in
    []
  } tag: {
    []
  }
}

extension GitClient: DependencyKey {
  public static let testValue: GitClient = .mock
}
