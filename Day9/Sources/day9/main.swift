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
extension Int {
  func hasSum(in pool: ArraySlice<Int>) -> Bool {
    pool.contains(where: { p in pool.contains(where: { $0 + p == self && $0 != p }) } )
  }
}

func findStar1(input: [Int]) -> Int {
  for idx in 25..<input.count {
    let pool = input[(idx - 25)..<idx]
    let target = input[idx]
    if !target.hasSum(in: pool) { return target }
  }
  fatalError("You frogged up, buddy.")
}

let (elapsed, star1) = time(findStar1(input: input))
print("The key is: \(star1) | Time elapsed: \(elapsed / 1_000)μs")

func findStar2(input: [Int], star1 target: Int) -> Int {
  var back = 0, sum = input[0]
  for front in input.indices {
    if sum == target { let range = input[back...front]; return range.min()! + range.max()! }
    let next = input[front + 1]
    while sum > target - next && back <= front {
      sum -= input[back]
      back += 1
    }
    sum += next
  }
  fatalError("Froggin' makes me feel good!")
}

let (elapsed2, star2) = time(findStar2(input: input, star1: star1))
print("star2: \(star2) | Time elapsed: \(elapsed2 / 1_000)μs")
