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
  .trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)

// MARK: - Real work happens here
struct Position: Hashable {
  let x: Int
  let y: Int
  let z: Int
  
  func move(_ direction: Substring) -> Position {
    switch direction {
    case "e": return Position(x: x+1, y: y-1, z: z)
    case "w": return Position(x: x-1, y: y+1, z: z)
    case "sw": return Position(x: x-1, y: y, z: z+1)
    case "ne": return Position(x: x+1, y: y, z: z-1)
    case "se": return Position(x: x, y: y-1, z: z+1)
    case "nw": return Position(x: x, y: y+1, z: z-1)
    default: fatalError("bad direction: \(direction)")
    }
  }
}

class Cell: Hashable {
  let position: Position
  let neighbors: [Position]
  var color: Bool // black: true, white: false
  var shouldFlip = false
  
  init(position: Position, black color: Bool = false) {
    self.position = position
    neighbors = ["e", "w", "ne", "nw", "se", "sw"].map { position.move($0[...]) }
    self.color = color
  }
  
  static func ==(lhs: Cell, rhs: Cell) -> Bool {
    lhs.position == rhs.position
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(position)
  }
  func flip() {
    color.toggle()
  }
  func flipIf() {
    if shouldFlip {
      color.toggle()
      shouldFlip.toggle()
    }
  }
}

struct Floor {
  var tiles: [Position: Cell]
  var steps: [Substring]
  var neighborhood = Set<Position>()
  
  init(_ input: [String]) {
    tiles = [Position: Cell]()
    steps = input.map { $0[...] }
  }
  
  mutating func step(_ moves: inout Substring) -> Substring? {
    guard !moves.isEmpty else { return nil }
    let stepSize = "ns".contains(moves.first!) ? 2 : 1
    let ret = moves.prefix(stepSize)
    moves.removeFirst(stepSize)
    return ret
  }
  
  mutating func move(_ moves: Substring) {
    var moves = moves, currentPosition = Position(x: 0, y: 0, z: 0)
    while let direction = step(&moves) {
      currentPosition = currentPosition.move(direction)
    }
    if let endCell = tiles[currentPosition] {
      endCell.flip()
    } else {
      tiles[currentPosition] = Cell(position: currentPosition, black: true)
    }
  }
  
  mutating func star1() -> Int {
    for moves in steps { move(moves) }
    return tiles.values.filter(\.color).count
  }
  
  mutating func fetchCell(_ pos: Position) -> Cell {
    if let c = tiles[pos] {
      return c
    } else {
      let c = Cell(position: pos)
      tiles[pos] = c
      return c
    }
  }

  mutating func prepareForUpdate() {
    neighborhood.removeAll()
    for cell in tiles.values where cell.color {
      neighborhood.insert(cell.position)
      neighborhood.formUnion(cell.neighbors)
    }
    for pos in neighborhood {
      let cell = fetchCell(pos)
      var nCount = 0
      for pos in cell.neighbors {
        if let neighbor = tiles[pos] {
          if neighbor.color { nCount += 1 }
        } else {
          let newCell = Cell(position: pos)
          tiles[pos] = newCell
        }
      }
      cell.shouldFlip = cell.color ? !(1...2 ~= nCount) : 2 == nCount
    }
  }
  
  mutating func update() {
    for cell in tiles.values {
      cell.flipIf()
    }
  }
  
  mutating func star2(_ generations: Int) -> Int {
    for _ in 1...generations {
      prepareForUpdate()
      update()
    }
    return tiles.values.filter(\.color).count
  }
}

// MARK: - Execution and timing
var floor = Floor(input)

var (elapsed, star) = time(floor.star1())
print("⭐️ There are \(star) black tiles | Time elapsed: \(elapsed / 1_000)μs")

(elapsed, star) = time(floor.star2(100))
print("🌟 There are \(star) black tiles after 100 days | Time elapsed: \(elapsed / 1_000)μs")
