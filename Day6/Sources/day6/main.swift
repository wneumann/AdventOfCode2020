    import Foundation

    let groups =
      try String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]), encoding: .utf8)
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
