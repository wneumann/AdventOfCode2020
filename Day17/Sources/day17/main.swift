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
typealias Tableaux = [Position: Cell]

struct Position: Hashable, Comparable {
  static func < (lhs: Position, rhs: Position) -> Bool {
    guard lhs.dimensions.count <= rhs.dimensions.count else { return false }
    for (l, r) in zip(lhs.dimensions, rhs.dimensions) {
      if l < r { return true } else if l > r { return false }
    }
    return false
  }
  
  let dimensions: [Int]
}

class Cell {
  let position: Position
  var active: Bool
  var nextState: Bool
  var neighbors: [Position]

  init(position: Position, state: Character) {
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
    neighbors = deltas.map { Position(dimensions: zip(position.dimensions, $0).map(+)) }
  }

  func prepareForUpdate(_ tableaux: Tableaux) {
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

func makeTableaux(_ input: [String], dimensions: Int = 3) -> Tableaux {
  var tableaux = Tableaux()
  let ext = Array(repeating: 0, count: dimensions - 2)
  for (y, row) in input.enumerated() {
    for (x, col) in row.enumerated() {
      let pos = Position(dimensions: [x, y] + ext)
      tableaux[pos] = Cell(position: pos, state: col)
    }
  }
  return tableaux
}

func updateX(tableaux: inout Tableaux) {
  let neighborhood = tableaux.values.map(\.neighbors).reduce(into: Set<Position>(), { $0.formUnion($1) })
  for position in neighborhood {
    if let cell = tableaux[position] {
      cell.prepareForUpdate(tableaux)
    } else { // add new cell
      let cell = Cell(position: position, state: ".")
      cell.prepareForUpdate(tableaux)
      tableaux[position] = cell
    }
  }
  for (_, cell) in tableaux { cell.update() }
}

// MARK: - Run the code, report the result
func star(_ dims: Int) -> Int {
  var tableaux = makeTableaux(input, dimensions: dims)
  for _ in 1...6 {
    updateX(tableaux: &tableaux)
  }
  return tableaux.values.filter(\.active).count
}

let (t1, value1) = time(star(3))
print("star 1: \(value1) | \(t1 / 1000)µs")

let (t2, value2) = time(star(4))
print("star 2: \(value2) | \(t2 / 1000)µs")
