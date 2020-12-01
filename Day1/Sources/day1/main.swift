import ArgumentParser
import Foundation

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL

  @Flag var skipPair = false
  @Flag var skipTriple = false
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here
func findPair(in expenses: ArraySlice<Int>, summingTo target: Int) -> (Int, Int)? {
  var pairSet = Set<Int>()
  for expense in expenses {
    let match = target - expense
    if pairSet.contains(expense) {
      return (expense, match)
    } else {
      pairSet.insert(match)
    }
  }
  return nil
}

let input = try String(contentsOf: options.inURL, encoding: .utf8)
var expenses = input.components(separatedBy: .newlines).compactMap(Int.init)[...]

if !options.skipPair {
  print("Looking for pairs:")
  if let (i, j) = findPair(in: expenses, summingTo: 2020) {
    print("\tFound pair: \(i) * \(j) = \(i * (j))")
  }
}

if !options.skipTriple {
  print("Looking for triplets:")
  while let i = expenses.popFirst() {
    if let (j, k) = findPair(in: expenses, summingTo: 2020 - i) {
      print("\tTriplets found: \(i) * \(j) * \(k) = \(i * j * k)")
      break
    }
  }
}
