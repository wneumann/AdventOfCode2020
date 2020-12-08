import Foundation

let input =
  try String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]), encoding: .utf8)
        .trimmingCharacters(in: .whitespacesAndNewlines)

enum Operation {
  case nop(Int)
  case jmp(Int)
  case acc(Int)
  case exit
  
  init(_ op: [String]) {
    guard op.count > 1, let value = Int(op[1]) else { fatalError("Bad op split: \(op)") }
    switch op[0] {
    case "nop": self = .nop(value)
    case "jmp": self = .jmp(value)
    case "acc": self = .acc(value)
    default: fatalError("Unknown opcode: \(op[0]): \(value)")
    }
  }
  
  mutating func flip() {
    switch self {
    case .jmp(let value): self = .nop(value)
    case .nop(let value): self = .jmp(value)
    default: ()
    }
  }
}

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
    } while !visited.contains(ip)
    return accumulator
  }
}

var program = input.components(separatedBy: .newlines).map { Operation($0.components(separatedBy: .whitespaces)) } + [.exit]
var m1 = Processor(program: program)
let star1StartTime = DispatchTime.now().uptimeNanoseconds
let final = m1.run()
let star1ElapsedTime = DispatchTime.now().uptimeNanoseconds - star1StartTime
print("The final accumulator value is: \(final) | Time elapsed: \(star1ElapsedTime / 1_000)μs")

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

let star2StartTime = DispatchTime.now().uptimeNanoseconds
let flipper = reachesZero(from: program.indices.last!, visited: [])
let star2ElapsedTime = DispatchTime.now().uptimeNanoseconds - star2StartTime

if let flipper = flipper {
  print("Faulty instruction: program[\(flipper)]: \(program[flipper])")
  program[flipper].flip()
  print("patched[\(flipper)]: \(program[flipper])")
  var m1 = Processor(program: program)
  let final = m1.run()
  print("The final accumulator value is: \(final) | Time elapsed: \(star2ElapsedTime / 1_000)μs")
} else {
  print("you frogged up, buddy")
}
