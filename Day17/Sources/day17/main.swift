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
//typealias Tableaux = [Position: Cell]
typealias TableauxX = [PositionX: CellX]

//struct Position: Hashable, Comparable {
//  let x: Int
//  let y: Int
//  let z: Int
//
//  static func < (lhs: Position, rhs: Position) -> Bool {
//    lhs.z < rhs.z
//      ? true
//      : lhs.z > rhs.z
//          ? false
//          : lhs.y < rhs.y
//              ? true
//              : lhs.y > rhs.y
//                  ? false
//                  : lhs.x < rhs.x
//  }
//
//  static func == (lhs: Position, rhs: Position) -> Bool {
//    (lhs.x, lhs.y, lhs.z) == (rhs.x, rhs.y, rhs.z)
//  }
//
//  func hash(into hasher: inout Hasher) {
//    hasher.combine(x)
//    hasher.combine(y)
//    hasher.combine(z)
//  }
//}

struct PositionX: Hashable, Comparable {
  static func < (lhs: PositionX, rhs: PositionX) -> Bool {
    guard lhs.dimensions.count <= rhs.dimensions.count else { return false }
    for (l, r) in zip(lhs.dimensions, rhs.dimensions) {
      if l < r { return true } else if l > r { return false }
    }
    return false
  }
  
  let dimensions: [Int]
}

class CellX {
  let position: PositionX
  var active: Bool
  var nextState: Bool
  var neighbors: [PositionX]

  init(position: PositionX, state: Character) {
    func mkDeltas(_ dimensions: Int) -> [[Int]] {
      func appendDelta(_ acc: [[Int]]) -> [[Int]] {
        (-1...1).reduce(into: [[Int]](), { res, i in res.append(contentsOf: acc.map { $0 + [i] }) })
      }
      return (1...dimensions)
        .reduce(into: ([[]] as [[Int]]), { base, _ in base = appendDelta(base) })
        .filter { $0 != Array(repeating: 0, count: dimensions) }
    }

    self.position = position
    active = state == "#"
    nextState = !active
    let deltas = mkDeltas(position.dimensions.count)
    neighbors = deltas.map { PositionX(dimensions: zip(position.dimensions, $0).map(+)) }
  }

  func prepareForUpdate(_ tableaux: TableauxX) {
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

//class Cell {
//  let position: Position
//  var active: Bool
//  var nextState: Bool
//  var neighbors: [Position]
//
//  init(position: Position, state: Character) {
//    self.position = position
//    active = state == "#"
//    nextState = !active
//    neighbors =
//      Array(
//        (-1...1).map { dx in
//          (-1...1).map { dy in
//            (-1...1).compactMap { dz in if
//              (dx, dy, dz) != (0,0,0) { return Position(x: position.x+dx, y: position.y+dy, z: position.z+dz) } else { return nil } }}.joined()}.joined()
//      )
//  }
//
//  func prepareForUpdate(_ tableaux: Tableaux) {
////    let cellState = { (b: Bool?) -> String in if let b = b { return b ? "#" : "." } else { return "_" }  }
////    let ns = neighbors.sorted().map { pos in "\(pos) : \(cellState(tableaux[pos]?.active))" }
////    print ("cell \(position) updating:\n\t\(ns.joined(separator: "\n\t"))")
//    let activeNeighbors = neighbors.compactMap { pos in tableaux[pos]?.active }.filter { $0 }.count
//    if active && !(2...3 ~= activeNeighbors) {
//      nextState = false
//    } else if !active && activeNeighbors == 3 {
//      nextState = true
//    } else {
//      nextState = active
//    }
//  }
//
//  func update() { active = nextState }
//}
//
//func printTableaux(_ tableaux: Tableaux) {
//  let (xl, yl, zl, xh, yh, zh) = tableaux.keys.reduce((Int.max, Int.max, Int.max, Int.min, Int.min, Int.min)) { b, v in
//    (min(b.0, v.x), min(b.1, v.y), min(b.2, v.z), max(b.3, v.x), max(b.4, v.y), max(b.5, v.z))
//  }
//  print((xl, yl, zl, xh, yh, zh))
//  for z in zl...zh {
//    print("\nz = \(z)")
//    for y in yl...yh {
//      for x in xl...xh {
//        if let c = tableaux[Position(x: x, y: y, z: z)], c.active { print("#", terminator: "") } else { print(".", terminator: "") }
//      }
//      print()
//    }
//  }
//}

//var tableaux = Tableaux()
//for (y, row) in input.enumerated() {
//  for (x, col) in row.enumerated() {
//    let pos = Position(x: x, y: y, z: 0)
//    tableaux[pos] = Cell(position: pos, state: col)
//  }
//}

var tableauxX = TableauxX()
for (y, row) in input.enumerated() {
  for (x, col) in row.enumerated() {
    let pos = PositionX(dimensions: [x, y, 0, 0]) //Position(x: x, y: y, z: 0)
    tableauxX[pos] = CellX(position: pos, state: col)
  }
}

//func update(tableaux: inout Tableaux) {
//  let neighborhood = tableaux.values.map(\.neighbors).reduce(into: Set<Position>(), { $0.formUnion($1) })
//  for position in neighborhood {
//    if let cell = tableaux[position] {
//      cell.prepareForUpdate(tableaux)
//    } else { // add new cell
//      let cell = Cell(position: position, state: ".")
//      cell.prepareForUpdate(tableaux)
//      tableaux[position] = cell
//    }
//  }
//  for (_, cell) in tableaux { cell.update() }
//}

func updateX(tableaux: inout TableauxX) {
  let neighborhood = tableaux.values.map(\.neighbors).reduce(into: Set<PositionX>(), { $0.formUnion($1) })
  for position in neighborhood {
    if let cell = tableaux[position] {
      cell.prepareForUpdate(tableaux)
    } else { // add new cell
      let cell = CellX(position: position, state: ".")
      cell.prepareForUpdate(tableaux)
      tableaux[position] = cell
    }
  }
  for (_, cell) in tableaux { cell.update() }
}

// MARK: - Run the code, report the result
//printTableaux(tableaux)

//update(tableaux: &tableaux)
//printTableaux(tableaux)
//
//update(tableaux: &tableaux)
//printTableaux(tableaux)
//
//update(tableaux: &tableaux)
//printTableaux(tableaux)

for _ in 1...6 {
  updateX(tableaux: &tableauxX)
}

let sum = tableauxX.values.filter(\.active).count
print("there are \(sum) active cells")
//let (t1, value1) = time(star1(lines))
//print("star 1: \(value1) | \(t1 / 1000)µs")
//
//let (t2, value2) = time(star2(lines))
//print("star 2: \(value2) | \(t2 / 1000)µs")
