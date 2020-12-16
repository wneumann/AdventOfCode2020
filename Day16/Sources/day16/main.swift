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
let ticket = input[1][1].components(separatedBy: ",").compactMap { Int($0) }
let otherTickets = input[2].dropFirst().map { $0.components(separatedBy: ",").compactMap { Int($0) } }
let rangeDict = Dictionary(uniqueKeysWithValues: rangeInput.map { ($0[0], makeRangeSet($0[1])) })
let validRanges = rangeDict.values.reduce(into: RangeSet<Int>(), { $0.formUnion($1) })

func star1() -> Int {
  otherTickets.joined().filter { !validRanges.contains($0) }.reduce(0, +)
}

func star2() -> Int {
  let validTickets = otherTickets.filter { ticket in ticket.allSatisfy {validRanges.contains($0) } }
  let getClassSet = { val in Set(rangeDict.compactMap { $0.value.contains(val) ? $0.key : nil }) }
  let classes = validTickets.map { ticket in ticket.map(getClassSet) }
  let intersections = classes.dropFirst().reduce(classes.first!) { ints, value in
    zip(ints, value).map { $0.0.intersection($0.1) }
  }
  var singles = [(offset: Int, element: Set<String>)]()
  var sets = Array(intersections.enumerated())
  while !sets.isEmpty {
    let eSingles = sets.filter { $0.element.count == 1 }
    let singlesSet = eSingles.dropFirst().reduce(eSingles.first!.element) { b, v in b.union(v.element) }
    sets = sets.compactMap { eSet in
      let removed = eSet.element.subtracting(singlesSet)
      return removed.isEmpty ? nil : (offset: eSet.offset, element: removed )
    }
    singles.append(contentsOf: eSingles)
  }
  let departures = singles.filter { $0.element.first!.hasPrefix("departure") }

  return departures.lazy.map(\.offset).map { ticket[$0] }.reduce(1, *)

}

// MARK: - Run the code, report the result
let (t1, value1) = time(star1())
print("star 1: \(value1) | \(t1 / 1000)µs")

let (t2, value2) = time(star2())
print("star 2: \(value2) | \(t2 / 1000)µs")
