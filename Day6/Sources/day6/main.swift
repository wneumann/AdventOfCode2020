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


// Alternate version using bit manipulation
let toBits = { (ch: Character) -> UInt32 in UInt32(1) << (ch.asciiValue! - 97) }
let countBits = { (ui: UInt32) -> Int in var n = ui, setBits = 0; while n > 0 { n = n & (n-1); setBits += 1}; return setBits }

let any = groups.map { countBits($0.map { $0.map(toBits).reduce(0,|) }.reduce(0,|)) }.reduce(0,+)
let all = groups.map { countBits($0.map { $0.map(toBits).reduce(0,|) }.reduce(UInt32.max,&)) }.reduce(0,+)

print("The total number of questions answered once by a group member is: ", any)
print("The total number of questions answered by all group members is: ", all)
