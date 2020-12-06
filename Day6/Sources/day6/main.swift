import ArgumentParser
import Foundation

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here
let groups =
  try String(contentsOf: options.inURL, encoding: .utf8)
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: "\n\n")
        .map { $0.components(separatedBy: .newlines) }

func uniques(_ arrs: [String]) -> Int {
  arrs.reduce(into: Set<Character>()) { base, value in
    base.formUnion(value)
  }.count
}

func repeats(_ arrs: [String]) -> Int {
  arrs.dropFirst().reduce(into: Set<Character>(arrs.first!)) { base, value in
    base.formIntersection(value)
  }.count
}

print("The total number of questions answered once by a group member: ", groups.map(uniques).reduce(0, +))
print("The total number of questions answered by all group members: ", groups.map(repeats).reduce(0,+))
