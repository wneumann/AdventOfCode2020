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
func eval(_ str: String, precedence p: (Character) -> Int) -> Int {
  var numStack = [Int](), opStack = [Character](), sstr = str[...]
  while !sstr.isEmpty {
    let ch = sstr.popFirst()!
    switch ch {
    case "0"..."9": numStack.append(Int(String(ch))!)
    case "(": opStack.append(ch)
    case ")":
      while let op = opStack.popLast(), op != "(" {
        guard let n1 = numStack.popLast(), let n2 = numStack.popLast() else { fatalError() }
        numStack.append(op == "+" ? n1 + n2 : n1 * n2)
      }
    case "+", "*":
      while !opStack.isEmpty, let topOp = opStack.last, p(ch) <= p(topOp) {
        let op = opStack.popLast()!
        guard let n1 = numStack.popLast(), let n2 = numStack.popLast() else { fatalError() }
        numStack.append(op == "+" ? n1 + n2 : n1 * n2)
      }
      opStack.append(ch)
    default:
      continue
    }
  }
  while !opStack.isEmpty {
    let op = opStack.popLast()!
    guard let n1 = numStack.popLast(), let n2 = numStack.popLast() else { fatalError() }
    numStack.append(op == "+" ? n1 + n2 : n1 * n2)
  }
  guard numStack.count == 1 else { fatalError() }
  return numStack.popLast()!
}

let prec1 = { (ch: Character) in ch == "(" ? 1 : 2 }
let prec2 = { (ch: Character) in ch == "(" ? 1 : ch == "*" ? 2 : 3 }

// MARK: - Run the code, report the result
func star(_ input: [String], precedence prec: (Character) -> Int) -> Int {
  input.map { eval($0, precedence: prec) }.reduce(0, +)
}

let (t1, value1) = time(star(input, precedence: prec1))
print("star 1: \(value1) | \(t1 / 1000)µs")

let (t2, value2) = time(star(input, precedence: prec2))
print("star 2: \(value2) | \(t2 / 1000)µs")
