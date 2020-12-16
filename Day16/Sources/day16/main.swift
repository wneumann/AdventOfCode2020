import Foundation
import SE0270_RangeSet

// MARK: - Utilty crud
func time<Res>(_ proc: @autoclosure () -> Res) -> (UInt64, Res) {
  let startTime = DispatchTime.now().uptimeNanoseconds
  let star = proc()
  let elapsedTime = DispatchTime.now().uptimeNanoseconds - startTime
  return (elapsedTime, star)
}

let input =
  try String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]), encoding: .utf8)
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: "\n\n")
        .map{ $0.components(separatedBy: "\n") }
  
func makeRangeSet(_ rangeStr: String) -> RangeSet<Int> {
    rangeStr.components(separatedBy: " or ").reduce(into: RangeSet<Int>()) { set, range in
    let splits = range.components(separatedBy: "-")
    let low = Int(splits[0])!, high = Int(splits[1])! + 1
    set.formUnion(RangeSet(low..<high))
  }
}

// MARK: - Real work happens here
let rangeInput = input[0].map { $0.components(separatedBy: ": ") }

let ticket = input[1][1].components(separatedBy: ",").compactMap { Int($0)! }

let otherTickets = input[2].dropFirst().map { $0.components(separatedBy: ",").compactMap { Int($0)! } }

let rangeDict = Dictionary(uniqueKeysWithValues: rangeInput.map { ($0[0], makeRangeSet($0[1])) })
let validRanges = rangeDict.values.reduce(into: RangeSet<Int>(), { $0.formUnion($1) })

let invalidNumbers = otherTickets.joined().filter { !validRanges.contains($0) }
print("invalid numbers: \(invalidNumbers), sum: \(invalidNumbers.reduce(0, +))")

// MARK: - Run the code, report the result
//let (t1, value1) = time(star1(lines))
//print("star 1: \(value1) | \(t1 / 1000)µs")
//
//let (t2, value2) = time(star2(lines))
//print("star 2: \(value2) | \(t2 / 1000)µs")
