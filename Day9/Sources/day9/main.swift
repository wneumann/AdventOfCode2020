import Foundation

let input =
  try String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]), encoding: .utf8)
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: "\n")
        .compactMap(Int.init)

extension Int {
  func hasSum(in pool: ArraySlice<Int>) -> Bool {
    let set = Set(pool)
    return set.contains { (val) -> Bool in
      self != 2 * val && set.contains(self - val)
    }
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

let star1StartTime = DispatchTime.now().uptimeNanoseconds
let star1 = findStar1(input: input)
let star1ElapsedTime = DispatchTime.now().uptimeNanoseconds - star1StartTime

print("The key is: \(star1) | Time elapsed: \(star1ElapsedTime / 1_000)μs")

func findStar2(input: [Int], star1 target: Int) -> Int {
  var back = 0, front = 0, sum = input[0]//, nums = input[(idx+1)...]
  while front < input.count {
    if sum == target { let range = input[back...front]; return range.min()! + range.max()! }
    let next = input[front + 1]
    while sum > target - next && back <= front {
      sum -= input[back]
      back += 1
    }
    front += 1
    sum += next
  }
  fatalError("Froggin' makes me feel good!")
}

let star2StartTime = DispatchTime.now().uptimeNanoseconds
let star2 = findStar2(input: input, star1: star1)
let star2ElapsedTime = DispatchTime.now().uptimeNanoseconds - star2StartTime

print("star2: \(star2) | Time elapsed: \(star2ElapsedTime / 1_000)μs")
