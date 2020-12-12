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
struct Ship {
  static let forward = [0: (0, 1), 90: (1, 0), 180: (0, -1), 270: (-1, 0)]
  var waypoint = (1, 10)
  var heading: Int
  var position: (Int, Int)
  var manhattan: Int { abs(position.0) + abs(position.1) }
  
  init() {
    heading = 0
    position = (0, 0)
  }
  
  mutating func move(command: String, value: Int) {
    switch command {
    case "N": position = (position.0 + value, position.1)
    case "S": position = (position.0 - value, position.1)
    case "E": position = (position.0, position.1 + value)
    case "W": position = (position.0, position.1 - value)
    case "R": heading = (heading + (360 - value)) % 360
    case "L": heading = (heading + (360 + value)) % 360
    case "F":
      guard let (y, x) = Ship.forward[heading] else { return }
      position = (position.0 + (y * value), position.1 + (x * value) )
    default: return
    }
  }
    
  mutating func steer(command: String, value: Int) {
    switch command {
    case "N": waypoint = (waypoint.0 + value, waypoint.1)
    case "S": waypoint = (waypoint.0 - value, waypoint.1)
    case "E": waypoint = (waypoint.0, waypoint.1 + value)
    case "W": waypoint = (waypoint.0, waypoint.1 - value)
    case "R": (0..<(value / 90)).forEach { _ in waypoint = (-waypoint.1, waypoint.0) }
    case "L": (0..<(value / 90)).forEach { _ in waypoint = (waypoint.1, -waypoint.0) }
    case "F": position = (position.0 + (waypoint.0 * value), position.1 + (waypoint.1 * value) )
    default: return
    }
  }
}

// MARK: - Execution and timing
func setup(input: [String]) -> [(String, Int)] {
  input.map {
    (String($0.first!), Int($0.dropFirst())!)
  }
}

let (elapsedSetup, commands) = time(setup(input: input))
print("Setup time elapsed: \(elapsedSetup / 1_000)μs")

func star1(input: [(String, Int)]) -> Int {
  var ship = Ship()
  for (command, value) in input { ship.move(command: command, value: value) }
  return ship.manhattan
}

var (elapsed, star) = time(star1(input: commands))
print("⭐️ The manhattan distance is: \(star) | Time elapsed: \(elapsed / 1_000)μs")

func star2(input: [(String, Int)]) -> Int {
  var ship = Ship()
  for (command, value) in input { ship.steer(command: command, value: value) }
  return ship.manhattan
}

(elapsed, star) = time(star2(input: commands))
print("🌟 The manhattan distance is: \(star) | Time elapsed: \(elapsed / 1_000)μs")
