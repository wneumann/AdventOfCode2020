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
struct Position: Hashable, Comparable {
  let x: Int
  let y: Int
  let z: Int

  static func < (lhs: Position, rhs: Position) -> Bool {
    lhs.z < rhs.z
      ? true
      : lhs.z > rhs.z
          ? false
          : lhs.y < rhs.y
              ? true
              : lhs.y > rhs.y
                  ? false
                  : lhs.x < rhs.x
  }
  
  static func == (lhs: Position, rhs: Position) -> Bool {
    (lhs.x, lhs.y, lhs.z) == (rhs.x, rhs.y, rhs.z)
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(x)
    hasher.combine(y)
    hasher.combine(z)
  }
}

class Cell {
  let position: Position
  var active: Bool
  var nextState: Bool
  var neighbors: [Position]
  
  init(position: Position, state: Character) {
    self.position = position
    active = state == "#"
    nextState = !active
    neighbors =
      Array(
        (-1...1).map { dx in
          (-1...1).map { dy in
            (-1...1).compactMap { dz in if
              (dx, dy, dz) != (0,0,0) { return Position(x: position.x+dy, y: position.y+dy, z: position.z+dz) } else { return nil } }}.joined()}.joined()
      )
  }
  
  func prepareForUpdate(_ tableaux: [Position: Cell]) {
    let activeNeighbors = neighbors.compactMap { pos in tableaux[pos]?.active }.filter { $0 }.count
    if active && !(2...3 ~= activeNeighbors) {
      nextState = false
    } else if !active && activeNeighbors == 3 {
      nextState = true
    } else {
      nextState = active
    }
  }
  
  func update() { active = nextState }
}

func printTableaux(_ tableaux: [Position: Cell]) {
  let (xl, yl, zl, xh, yh, zh) = tableaux.keys.reduce((Int.max, Int.max, Int.max, Int.min, Int.min, Int.min)) { b, v in
    (min(b.0, v.x), min(b.1, v.y), min(b.2, v.z), max(b.0, v.x), max(b.1, v.y), max(b.2, v.z))
  }
  for z in zl...zh {
    print("z = \(z)")
    for y in yl...yh {
      for x in xl...xh {
        if let c = tableaux[Position(x: x, y: y, z: z)], c.active { print("#", terminator: "") } else { print(".", terminator: "") }
      }
    }
    print("\n")
  }
  print("\n")
}

var tableaux = [Position: Cell]()
for (y, row) in input.enumerated() {
  for (x, col) in row.enumerated() {
    let pos = Position(x: x, y: y, z: 0)
    tableaux[pos] = Cell(position: pos, state: col)
  }
}

// MARK: - Run the code, report the result
printTableaux(tableaux)


//let (t1, value1) = time(star1(lines))
//print("star 1: \(value1) | \(t1 / 1000)µs")
//
//let (t2, value2) = time(star2(lines))
//print("star 2: \(value2) | \(t2 / 1000)µs")
