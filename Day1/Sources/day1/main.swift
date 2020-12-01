import ArgumentParser
import Foundation

struct PairFinder: ParsableCommand {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL
  
  private func findPair(expenses: ArraySlice<Int>, target: Int) -> (Int, Int)? {
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

  mutating func run() throws {
    guard
      let input = try? String(contentsOf: inURL, encoding: .utf8)
        .trimmingCharacters(in: .whitespacesAndNewlines)
    else { fatalError("Invalid file path") }
    var expenses: ArraySlice<Int> = input.components(separatedBy: .newlines).map {
      guard let i = Int($0) else { fatalError("Invald input: Could not convert \($0) to Int") }
      return i
    }.sorted()[...]
    print("Looking for pairs:")
    if let (i,j) = findPair(expenses: expenses, target: 2020) {
      print("\tFound pair: \(i) * \(j) = \(i * (j))")
    } else {
      fatalError("No pairs found")
    }

    print("Looking for triplets:")
    let maxMin = 2020 / 3
    while let i = expenses.popFirst(), i < maxMin {
      let target = 2020 - i
      if let (j, k) = findPair(expenses: expenses, target: target) {
        print("\tTriplets found: \(i) * \(j) * \(k) = \(i * j * k)")
        return
      }
    }
    print("No triplets found")
  }
}

PairFinder.main()
