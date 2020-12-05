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
        .components(separatedBy: .newlines)

let seatID: (String) -> Int = { $0.reduce(0) { return $0 * 2 + ("FL".contains($1) ? 0 : 1) } }

let seatIDs = input.map(seatID).sorted(by: >)

print("The highest seat ID is \(seatIDs.first!)")

let gaps = zip(seatIDs, seatIDs.dropFirst())
if let gap = gaps.first(where: { $0.0 - $0.1 == 2 }) {
  print("Your seat ID is:", gap.0 - 1)
} else {
  print("no gap?")
}
