public struct ReleaseNotes {
  let version: SemanticVersion
  let conventionalCommits: [ConventionalCommit]

  var containsBreakingChange: Bool {
    conventionalCommits.contains { $0.isBreaking }
  }

  public init(
    version: SemanticVersion,
    conventionalCommits: [ConventionalCommit]
  ) {
    self.version = version
    self.conventionalCommits = conventionalCommits
  }

  var markdown: String {
    var groupedCommits: [String: [ConventionalCommit]] = [:]
    for conventionalCommit in conventionalCommits {
      if groupedCommits[conventionalCommit.type.friendlyName] == nil {
        groupedCommits[conventionalCommit.type.friendlyName] = []
      }
      groupedCommits[conventionalCommit.type.friendlyName]?.append(conventionalCommit)
    }

    let notes = groupedCommits.keys.sorted { lhs, rhs in
      if lhs.lowercased().contains("breaking") {
        return true
      } else if rhs.lowercased().contains("breaking") {
        return false
      } else if lhs.lowercased().contains("feature") {
        return true
      } else if rhs.lowercased().contains("feature") {
        return false
      } else if lhs.lowercased().contains("bug fix") {
        return true
      } else if rhs.lowercased().contains("bug fix") {
        return false
      } else if lhs.lowercased().contains("hotfix") {
        return true
      } else if rhs.lowercased().contains("hotfix") {
        return false
      }

      return lhs < rhs
    }.map {
      "### \($0.englishPluralized)\n" + (groupedCommits[$0] ?? []).map { "* \($0.description) (\($0.hash))" }.joined(separator: "\n")
    }

    return """
    ## \(version.tag)\n
    \(notes.joined(separator: "\n\n").replacingOccurrences(of: "\"", with: "\\\""))
    """
  }

  public var json: String {
    """
    {
      "version" : "\(version.tag)",
      "containsBreakingChange" : \(containsBreakingChange),
      "releaseNotes" : "\(markdown.replacingOccurrences(of: "\n", with: "\\n"))"
    }
    """
  }
}

extension String {
  fileprivate var englishPluralized: Self {
    if self.last?.needsEBeforeSInEnglish == true {
      return "\(self)es"
    } else if self.last?.needsNoPluralizationInEnglish == true {
      return self
    }
    return "\(self)s"
  }
}

extension Character {
  fileprivate var needsEBeforeSInEnglish: Bool {
    self == "x"
  }

  fileprivate var needsNoPluralizationInEnglish: Bool {
    self == "s"
  }
}
