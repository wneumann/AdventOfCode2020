import ArgumentParser
import Foundation

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here
let input =
  try String(contentsOf: options.inURL, encoding: .utf8)
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .newlines)

let seatID = { (pass: String) in pass.reduce(0) { $0 * 2 + ("FL".contains($1) ? 0 : 1) } }

let seatIDs = input.map(seatID).sorted(by: >)
print("The highest seat ID is \(seatIDs.first!)")

let gaps = zip(seatIDs, seatIDs.dropFirst())
if let gap = gaps.first(where: { $0.0 - $0.1 == 2 }) {
  print("Your seat ID is:", gap.0 - 1)
} else {
  print("no gap? You need to fix your code.")
}


// Single pass, no sort version
let (minSeat, maxSeat, sum) =
  input
    .lazy
    .map(seatID)
    .reduce((Int.max, Int.min, 0)) { base, value in
      if value == 0  { print("Found a zero!") }
      return (min(base.0, value), max(base.1, value), base.2 + value)
    }

let expectedSum = (minSeat + maxSeat) * (maxSeat - minSeat + 1) / 2
print("The highest seat ID is also \(maxSeat).\nYour seat ID is also \(expectedSum - sum)")
