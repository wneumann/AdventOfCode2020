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

// MARK: - Real work happens here

// MARK: - Run the code, report the result
//let (t1, value1) = time(star1(lines))
//print("star 1: \(value1) | \(t1 / 1000)µs")
//
//let (t2, value2) = time(star2(lines))
//print("star 2: \(value2) | \(t2 / 1000)µs")
