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
enum Oper: Character {
  case plus = "+", times = "*"
}

enum Expr: CustomStringConvertible {
  case num(Int)
  indirect case add(Expr, Expr)
  indirect case mult(Expr, Expr)
  
  var description: String {
    switch self {
    case .num(let n): return "\(n)"
    case let .exp(e1, op, e2):
      return "[\(e1) \(op.rawValue) \(e2)]"
    }
  }
}

func parse(_ str: inout Substring) -> (Expr, Substring) {
  var exp: Expr?
  var op: Oper?
  let pristine = String(str)
  
  while !str.isEmpty {
    let ch = str.popFirst()!
    switch ch {
    case "0"..."9":
      let digit = Expr.num(Int(String(ch))!)
      if let e1 = exp, let o = op { exp = .exp(e1, o, digit); op = nil } else { exp = digit }
    case "+", "*":
      if exp != nil {
        if op == nil {
          op = Oper(rawValue: ch)!
        } else {
          fatalError("'+' found following op \(op!) - pristine: \(pristine)")
        }
      } else { fatalError("'+' found without leading expr' - pristine: \(pristine)") }
     case "(":
      let (ex, ss) = parse(&str)
      str = ss
      if let e1 = exp, let o = op {  exp = .exp(e1, o, ex); op = nil } else { exp = ex }
    case ")":
      guard exp != nil, op == nil else { fatalError("incomplete expr ending with ')' - pristine: \(pristine)") }
      return (exp!, str)
    default: continue
    }
  }
  if let e = exp {
    if let o = op { fatalError("weirdness hanging off end - pristine: \(pristine) exp: \(e), op: \(o)") } else { return (e, str) }
  } else {
    fatalError("nothing found? pristine: \(pristine)")
  }
}

func runParser(_ str: String) -> Expr {
  var ss = str[...]
  let (exp, _) = parse(&ss)
  return exp
}

func eval(_ expr: Expr) -> Int {
  switch expr {
  case .num(let n): return n
  case let .exp(e1, op, e2):
    let i1 = eval(e1), i2 = eval(e2)
    switch op {
    case .plus: return i1 + i2
    case .times: return i1 * i2
    }
  }
}

// MARK: - Run the code, report the result
func star(_ input: [String]) -> Int {
  input.lazy.map(runParser).map(eval).reduce(0, +)
}

let (t1, value1) = time(star(input))
print("star 1: \(value1) | \(t1 / 1000)µs")

//let (t2, value2) = time(star(4, 6))
//print("star 2: \(value2) | \(t2 / 1000)µs")
//
//let (t3, value3) = time(star(6, 4))
//print("star 3: \(value3) | \(t3 / 1000)µs")
