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
        .components(separatedBy: "\n\n")

// MARK: - Real work happens here
enum Rule: CustomStringConvertible {
  case term(String)
  case nonterm(Int)
  
  var description: String {
    switch self {
    case .term(let t): return "\(t)"
    case .nonterm(let i): return "#\(i)"
    }
  }
}

indirect enum Prod: CustomStringConvertible {
  case rule(Rule)
  case cons(Prod, Prod)
  case either(Prod, Prod)
  
  var description: String {
    switch self {
    case .rule(let r): return "\(r)"
    case let .cons(r1, r2): return "(\(r1) + \(r2))"
    case let .either(r1, r2): return "(\(r1) | \(r2))"
    }
  }
}

func parseRule(_ rules: [String]) -> Prod {
  let pTerm = { (str: String) in Prod.rule(.term(String(str.dropFirst().first!))) }
  let pNon = { (str: String) in Prod.rule(.nonterm(Int(str)!)) }
  let pCons: (String) -> Prod = { str in let split = str.components(separatedBy: .whitespaces).map(pNon); return Prod.cons(split[0], split[1]) }
  let pEither: ([String]) -> Prod = { strs in  let conses = strs.map(pCons); return Prod.either(conses[0], conses[1])}
  if rules.count > 1 { return pEither(rules) }
  let rule = rules[0]
  if rule.hasPrefix("\"") { return pTerm(rule) }
  return rule.contains(" ") ? pCons(rule) : pNon(rule)
}

let rawRules = input[0].components(separatedBy: "\n").map { (rule: String) -> (Int, Prod) in
  let rs = rule.components(separatedBy: ": ")
  let ruleNum = Int(rs[0])!
  let cons = rs[1].components(separatedBy: " | ")
  let rule = parseRule(cons)
  return (ruleNum, rule)
}

// MARK: - Run the code, report the result
//func star(_ input: [String]) -> Int) -> Int {
//}
//
//let (t1, value1) = time(star(input, precedence: prec1))
//print("star 1: \(value1) | \(t1 / 1000)µs")
//
//let (t2, value2) = time(star(input, precedence: prec2))
//print("star 2: \(value2) | \(t2 / 1000)µs")
