import Foundation

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
        .components(separatedBy: "\n")
        .compactMap(Int.init)

// MARK: - Real work happens here
func setup(input: [Int]) -> ([Int], [Int]) {
  var sorted = input.sorted()
  sorted = [0] + sorted + [sorted.last! + 3]
  let gaps = zip(sorted.dropFirst(), sorted).map(-)
  return (sorted, gaps)
}

let (setupTime, (sorted, gaps)) = time(setup(input: input))
print("Setup time: \(setupTime / 1_000)µs")

func oneThreeProduct() -> Int {
  let (ones, threes) = gaps.reduce((0, 0)) { $1 == 1 ? ($0.0 + 1, $0.1) : ($0.0, $0.1 + 1) }
  return ones * threes
}


let (elapsed, star1) = time(oneThreeProduct())
print("The product is: \(star1) | Time elapsed: \(elapsed / 1_000)μs")

func oneruns(_ gaps: [Int]) -> [Int] {
  var runs = [Int](), run = 1
  for gap in gaps {
    if gap == 1 { run += 1 } else { runs.append(run); run = 1 }
  }
  return runs
}

func numPaths(_ runLength: Int) -> Int {
  guard runLength > 1 else { return 1 }
  let choose = { (n: Int, k: Int) -> Int in
    switch k {
    case 0, 1: return 1
    case 2: return (n * n - n) / 2
    default: fatalError("this problem limits k to 0..2")
    }
  }
  
  let mids = runLength - 2
  let choices = min(mids, 2)
  
  return (0...choices).map({ choose(mids, $0) }).reduce(0, +)
}

func totalPaths() -> Int {
  oneruns(gaps).map(numPaths).reduce(1, *)
}

let (elapsed2, star2) = time(totalPaths())
print("The total number of paths is: \(star2) | Time elapsed: \(elapsed2 / 1_000)μs")
