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

enum Line {
  case mask(Substring)
  case mem(addr: Int, val: Int)
  init(_ str: String) {
    if str.hasPrefix("mask = ") {
      self = .mask(str.dropFirst(7))
    } else {
      let addr = Int(str.dropFirst(4).prefix(while: { $0.isWholeNumber }))!
      let val = Int(str.components(separatedBy: " = ")[1])!
      self = .mem(addr: addr, val: val)
    }
  }
}

func star1(_ input: [Line]) -> Int {
  var memory = [Int: Int](), mask = String(repeating: "X", count: 36)[...]
  input.forEach { instruction in
    switch instruction {
    case let .mask(newMask): mask = newMask
    case let .mem(addr: addr, val: val):
      var maskedVal = val
      for (bit, pos) in zip(mask,(0..<36).reversed()) {
        if bit == "1" {
          maskedVal |= (1 << pos)
        } else if bit == "0" {
          maskedVal &= ~(1 << pos)
        }
      }
//      print("mam[\(addr)] <- \(maskedVal)")
      memory[addr] = maskedVal
    }
  }
  return memory.values.reduce(0, +)
}

func intMask(address: Int, mask: Substring, key: Int) -> String {
  var maskedAddress = "", keyVal = key, addressVal = address
  for bit in mask.reversed() {
    switch bit {
    case "0":
      maskedAddress.append(addressVal & 1 == 1 ? "1" : "0")
    case "1":
      maskedAddress.append("1")
    default: // "X"
      maskedAddress.append(keyVal & 1 == 1 ? "1" : "0")
      keyVal >>= 1
    }
    addressVal >>= 1
  }
//  return Int(String(maskedAddress.reversed()), radix: 2)!
  return maskedAddress
}


func star2(_ input: [Line]) -> Int {
  var memory = [String: Int](), mask = String(repeating: "X", count: 36)[...]

  input.forEach { instruction in
    switch instruction {
    case .mask(let newMask): mask = newMask
    case let .mem(addr: addr, val: val):
      let addys = (0..<(1 << mask.filter({ $0 == "X"}).count))
      let addresses = addys.map { intMask(address: addr, mask: mask, key: $0) }
      addresses.forEach { memory[$0] = val }
    }
  }

  return memory.values.reduce(0, +)
}

// MARK: - Run the code, report the result
let lines = input.map(Line.init)
let (t1, value1) = time(star1(lines))
print("star 1: \(value1) | \(t1 / 1000)µs")

let (t2, value2) = time(star2(lines))
print("star 2: \(value2) | \(t2 / 1000)µs")
