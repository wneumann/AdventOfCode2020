import Foundation

let inputA =
  try String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]), encoding: .utf8)
        .trimmingCharacters(in: .whitespacesAndNewlines)
//        .components(separatedBy: "\n")

let input = """
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
"""

enum Operation {
  case nop(Int)
  case jmp(Int)
  case acc(Int)
  case exit
  
  init(opcode: String, value: Int) {
    switch opcode {
    case "nop": self = .nop(value)
    case "jmp": self = .jmp(value)
    case "acc": self = .acc(value)
    default: fatalError("Unknown opcode: \(opcode): \(value)")
    }
  }
}

let opParser =
  Parser.star(
    zip(with: { Operation(opcode: $0, value: $1) },
        Parser.keep(.choice([.string("nop"), .string("jmp"), .string("acc")]), discard: Parser.whitespace),
        Parser.int
    ),
    separatedBy: .newlines
  )

struct Processor {
  private let tape: [Operation]
  private var ip = 0
  private var visited = Set<Int>()
  public private(set) var accumulator = 0
 
  init(program: [Operation]) {
    tape = program
  }
  
  mutating func run() -> Int {
    repeat {
//      print("ip: \(ip), acc: \(accumulator), visited: \(visited.sorted()), op: \(tape[ip])")
      visited.insert(ip)
      switch tape[ip] {
      case .nop: ip += 1
      case .acc(let amount):
        ip += 1
        accumulator += amount
      case .jmp(let offset):
        ip += offset
      case .exit: return accumulator
      }
//      print("new IP: \(ip), quitting? \(visited.contains(ip) ? "yep" : "nope")")
    } while !visited.contains(ip)
    return accumulator
  }
}

let program = try opParser.run(inputA).match.get() + [.exit]
var m1 = Processor(program: program)
let final = m1.run()
print("The final accumulator value is: \(final)")

func reachesZero(from instruction: Int, visited: Set<Int>, flipped: Int? = nil) -> Int? {
    let reaches: (Int) -> Bool = { ip in
      switch program[ip] {
      case .acc, .nop: return ip + 1 == instruction
      case .jmp(let offset): return ip + offset == instruction
      case .exit: return false
      }
    }
    let canReach: (Int) -> Bool = { ip in
      switch program[ip] {
      case .acc(_), .exit: return false
      case .jmp: return ip + 1 == instruction
      case .nop(let offset): return ip + offset == instruction
      }
    }
  guard instruction != 0 else { return flipped }
  if visited.contains(instruction) { return nil }
  let reachables = program.indices.filter(reaches)
  for r in reachables {
    if let flip = reachesZero(from: r, visited: visited.union([instruction]), flipped: flipped) { return flip }
  }
  if flipped == nil {
    return program.indices.lazy.filter(canReach).compactMap { reachesZero(from: $0, visited: visited.union([instruction]), flipped: $0) }.first
  }
  return nil
}

func patch(program: [Operation], at idx: Int) -> [Operation] {
  var p2 = program
  switch program[idx] {
  case .jmp(let value): p2[idx] = .nop(value)
  case .nop(let value): p2[idx] = .jmp(value)
  default: break
  }
  return p2
}

if let flipper = reachesZero(from: program.indices.last!, visited: []) {
  print("reaches zero: program[\(flipper)]: \(program[flipper])")
  let patched = patch(program: program, at: flipper)
  var m1 = Processor(program: patched)
  let final = m1.run()
  print("The final accumulator value is: \(final)")
} else {
  print("you frogged up, buddy")
}
