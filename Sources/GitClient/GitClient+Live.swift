import Foundation
import Model

extension GitClient {
  public static let liveValue: GitClient = GitClient { tag in
    let arguments = [
      "--no-pager",
      "log",
      tag == nil ? "" : "\(tag!)..HEAD",
      "--no-merges",
      "--pretty=\"%h \(GitCommit.Constants.fieldSeparator) %s \(GitCommit.Constants.fieldSeparator) %b \n-@-@-@-@-@-@-@-@\n\"",
    ]
    let log = shell(
      command: "git",
      arguments: arguments,
      environmentVariables: [:],
      outputFile: nil
    )

    return log.components(separatedBy: "-@-@-@-@-@-@-@-@")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { $0.isEmpty == false }
      .compactMap  { GitCommit($0) }
  } tag: {
    let tag = shell(
      command: "git tag",
      arguments: [],
      environmentVariables: [:],
      outputFile: nil
    )

    return tag.split(separator: "\n").map { String($0) }
  }
}

private func shell(
  command: String,
  arguments: [String],
  environmentVariables: [String: String],
  outputFile: String?
) -> String {
  let scriptOutputFile: String

  if let outputFile = outputFile {
      scriptOutputFile = " > \(outputFile)"
  } else {
      scriptOutputFile = ""
  }

  let script = "\(command) \(arguments.joined(separator: " "))" + scriptOutputFile

  let task = Process()
  task.launchPath = "/bin/sh"
  task.arguments = ["-c", script]
  task.environment = mergeEnvs(localEnv: environmentVariables, processEnv: ProcessInfo.processInfo.environment)
  task.currentDirectoryPath = FileManager.default.currentDirectoryPath

  let pipe = Pipe()
  task.standardOutput = pipe

  do {
    try task.run()
  } catch let error as NSError {
    print(error.localizedDescription)
    return ""
  }

  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  return String(data: data, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
}

private func mergeEnvs(localEnv: [String: String], processEnv: [String: String]) -> [String: String] {
    localEnv.merging(processEnv, uniquingKeysWith: { _, envString -> String in
        envString
    })
}