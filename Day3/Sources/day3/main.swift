import ArgumentParser
import Foundation

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here
// They really need to get Hashable synthesis for tuples already…
public struct Point<T: Hashable>: Hashable {
  let x: T
  let y: T
}

struct Hill {
  let length: Int
  let width: Int
  let trees: Set<Point<Int>>
  
  init(_ input: String) {
    let hill = input.components(separatedBy: .newlines)
    length = hill.count
    width = hill.first?.count ?? 0
    trees = hill.enumerated().reduce(into: Set<Point<Int>>()) { trees, row in
      row.element.enumerated().forEach { cell in
        if cell.element == "#" {
          trees.insert(Point(x: cell.offset, y: row.offset))
        }
      }
    }
  }
  
  func countTrees(forSlopes slopes: [(across: Int, down: Int)]) -> [Int] {
    slopes.map { slope -> Int in
      zip(
        (0...).lazy.map { $0 * slope.across % width },
        stride(from: 0, to: length, by: slope.down)
      ).reduce(0) { treesHit, square in
        treesHit + (trees.contains(Point(x: square.0, y: square.1)) ? 1 : 0)
      }
    }
  }

}


let input = try String(contentsOf: options.inURL, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

let star1Slopes = [(across: 3, down: 1)]
let star2Slopes = [
  (across: 1, down: 1),
  (across: 3, down: 1),
  (across: 5, down: 1),
  (across: 7, down: 1),
  (across: 1, down: 2)
]

let hill = Hill(input)
let trees1 = hill.countTrees(forSlopes: star1Slopes)
let trees2 = hill.countTrees(forSlopes: star2Slopes)
print("Product of trees on slope 1: \(trees1.reduce(1, *))")
print("Product of trees on slope 2: \(trees2.reduce(1, *))")


// Initial quick and dirty version just to get an answer
// It works, but it's less general, especially for fractional slopes
//
//var trees = 0
//for (row,i) in zip(hill, 0...) {
//  let col = i * 3 % row.count
//  if let square = row.dropFirst(col).first, square == "#" { trees += 1 }
//}
//
//print("\(trees) trees encountered")
//
//var mTrees = [1: 0, 3: 0, 5: 0, 7: 0]
//var hTree = 0
//let slopes = [1, 3, 5, 7]
//for (row,i) in zip(hill, 0...) {
//  for slope in slopes {
//    let col = i * slope % row.count
//    if let square = row.dropFirst(col).first, square == "#" { mTrees[slope, default: 0] += 1 }
//  }
//  if i.isMultiple(of: 2) {
//    let col = (i/2) % row.count
//    if let square = row.dropFirst(col).first, square == "#" { hTree += 1 }
//  }
//
//}
//
//print("mTrees: \(mTrees), hTree \(hTree)")
//print(mTrees.values.reduce(hTree, *), "trees encountered")

