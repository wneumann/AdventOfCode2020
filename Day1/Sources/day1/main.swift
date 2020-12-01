import ArgumentParser
import Foundation

struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL

  @Flag var skipPair = false
  @Flag var skipTriple = false
}

func findPair(expenses: ArraySlice<Int>, target: Int) -> (Int, Int)? {
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

let options = RunOptions.parseOrExit()

guard
  let input = try? String(contentsOf: options.inURL, encoding: .utf8)
else { fatalError("Invalid file path") }

var expenses: ArraySlice<Int> = input.components(separatedBy: .newlines).compactMap(Int.init)
  .sorted()[...]

if !options.skipPair {
  print("Looking for pairs:")
  if let (i, j) = findPair(expenses: expenses, target: 2020) {
    print("\tFound pair: \(i) * \(j) = \(i * (j))")
  }
}

if !options.skipTriple {
  print("Looking for triplets:")
  let maxMin = 2020 / 3
  while let i = expenses.popFirst(), i < maxMin {
    let target = 2020 - i
    if let (j, k) = findPair(expenses: expenses, target: target) {
      print("\tTriplets found: \(i) * \(j) * \(k) = \(i * j * k)")
    }
  }
}
