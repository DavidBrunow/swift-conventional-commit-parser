import Foundation

public struct ConventionalCommit: Equatable {
  public enum CommitType: Equatable {
    public enum Known: String {
      case breakingFeat
      case breakingFix
      case feat
      case fix
      case hotfix

      var friendlyName: String {
        switch self {
        case .breakingFeat:
          return "Breaking Change Feature"
        case .breakingFix:
          return "Breaking Change Bug Fix"
        case .feat:
          return "Feature"
        case .fix:
          return "Bug Fix"
        case .hotfix:
          return "Hotfix"
        }
      }
    }

    case known(Known)
    case unknown(String)

    public var friendlyName: String {
      switch self {
      case let .known(value):
        return value.friendlyName
      case let .unknown(value):
        return value.capitalized
      }
    }
  }
  public var description: String
  public var hash: String
  public var isBreaking: Bool {
    type == .known(.breakingFeat) || type == .known(.breakingFix)
  }
  public var scope: String?
  public var type: CommitType

  public init(
    description: String,
    hash: String,
    scope: String?,
    type: CommitType
  ) {
    self.description = description
    self.hash = hash
    self.scope = scope
    self.type = type
  }

  public init?(commit: GitCommit) {
    guard let colonIndex = commit.subject.firstIndex(of: ":") else {
      return nil
    }
    let firstInvalidCharacterBeforeColonIndex = commit.subject.firstIndex {
      $0.isLetter == false && $0 != "(" && $0 != ")" && $0 != "!"
    }
    if firstInvalidCharacterBeforeColonIndex ?? commit.subject.endIndex < colonIndex {
      return nil
    }
    let type = commit.subject.prefix(upTo: colonIndex).lowercased()

    let scope: String?

    if let firstOpeningParenIndex = type.firstIndex(of: "("),
       let firstClosingParentIndex = type.firstIndex(of: ")") {
      scope = String(type[firstOpeningParenIndex...firstClosingParentIndex]) // .substring(with: )
    } else {
      scope = nil
    }

    let typeWithoutScope = type.replacingOccurrences(of: scope ?? "", with: "")

    switch typeWithoutScope {
    case "feat":
      self.type = .known(.feat)
      // TODO: Handle breaking in footer
    case "feat!":
      self.type = .known(.breakingFeat)
    case "fix":
      self.type = .known(.fix)
      // TODO: Handle breaking in footer
    case "fix!":
      self.type = .known(.breakingFix)
    case "hotfix":
      self.type = .known(.hotfix)
    default:
      self.type = .unknown(typeWithoutScope)
    }

    self.description = String(commit.subject.suffix(from: commit.subject.index(after: colonIndex))).trimmingCharacters(in: .whitespacesAndNewlines)
    self.hash = commit.hash
    self.scope = scope?.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
  }
}
