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
  case nop
  case jmp(Int)
  case acc(Int)
  
  init(opcode: String, value: Int) {
    switch opcode {
    case "nop": self = .nop
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
      }
//      print("new IP: \(ip), quitting? \(visited.contains(ip) ? "yep" : "nope")")
    } while !visited.contains(ip)
    return accumulator
  }
}

let program = try opParser.run(inputA).match.get()
var m1 = Processor(program: program)
let final = m1.run()
print("The final accumulator value is: \(final)")
