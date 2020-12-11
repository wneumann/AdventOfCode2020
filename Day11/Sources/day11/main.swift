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

enum State: CustomStringConvertible {
  case occupied, empty, floor
  
  init(_ ch: Character) {
    self = ch == "L" ? .empty : .floor
  }
  var isOccupied: Bool { self == .occupied }
  var isEmpty: Bool { self != .occupied }
  var description: String {
    switch self {
    case .empty: return "L"
    case .occupied: return "#"
    case .floor: return "."
    }
  }
}

class Cell: CustomStringConvertible {
  var state: State
  var next: State
  var neighbors = [Cell]()
  var tolerance: Int
  var description: String { state.description }
  var isSteadyState: Bool { state == next }
  
  init(_ ch: Character, tolerance: Int) {
    state = State(ch)
    self.tolerance = tolerance
    next = state
  }
  
  @discardableResult func prepareForUpdate() -> Bool {
    guard state != .floor else { return false }
    let neighborhood = neighbors.map(\.state)
    if state == .occupied && neighborhood.filter(\.isOccupied).count >= tolerance {
      next = .empty
      return true
    } else if .empty == state && neighborhood.allSatisfy(\.isEmpty) {
      next = .occupied
      return true
    } else {
      return false
    }
  }
  
  func update() {
    state = next
  }
}

struct Ferry: CustomStringConvertible {
  var cells: [[Cell]]
  private var rows: Range<Int>
  private var cols: Range<Int>
  private let tolerance: Int
  var description: String {
    cells.map { row in
      row.map(\.description).joined()
    }.joined(separator: "\n") + "\n"
  }
  var occupied: Int { cells.map({ $0.filter { $0.state.isOccupied }.count }).reduce(0, +) }
  
  init(_ input: [String], tolerance: Int = 4, visible: Bool = false) { //, gatherNeighbors: (Int, Int, [Cell]) -> [Cell]) {
    cells = input.map { row in row.map { Cell($0, tolerance: tolerance) } }
    rows = cells.indices
    cols = cells[0].indices
    self.tolerance = tolerance
    
    for (r, row) in cells.enumerated() {
      for (c, cell) in row.enumerated() {
        cell.neighbors = getNeighbors(of: (r, c), visible: visible)
      }
    }
  }
  
  private func getNeighbors(of rc: (Int, Int), visible: Bool) -> [Cell] {
    let (r,c) = rc
    let directions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
    func look(_ direction: (Int, Int)) -> Cell? {
      var (y, x) = direction, (r,c) = (r+y, c+x), steps = visible ? Int.max : 1
      while rows ~= r && cols ~= c && steps > 0 {
        steps -= 1
        let cell = cells[r][c]
        if cell.state != .floor { return cell }
        (r, c) = (r+y, c+x)
      }
      return nil
    }
    
    return directions.compactMap(look)
  }

  @discardableResult func update() -> Bool {
    let stillEvolving = cells.reduce(false) { evolving, row in
      row.reduce(false) { changed, cell in cell.prepareForUpdate() || changed }  || evolving
    }
    if stillEvolving {
      cells.forEach { row in row.forEach { $0.update() } }
      return true
    } else {
      return false
    }
  }
  
  func run(debug: Bool = false) {
    if debug { print(description) }
    var safety = 0, stillEvolving: Bool
    repeat {
      stillEvolving = update()
      if debug { print(description) }
      safety += 1
    } while stillEvolving && safety < 1000
  }
}

// MARK: - Run the code, report the result
func star1(debug: Bool = false) -> Int {
  let ferry = Ferry(input)
  ferry.run(debug: debug)
  return ferry.occupied
}

let (t1, value1) = time(star1(debug: false))
print("star 1: \(value1) | \(t1 / 1000)µs")

func star2(debug: Bool = false) -> Int {
  let ferry = Ferry(input, tolerance: 5, visible: true)
  ferry.run(debug: debug)
  return ferry.occupied
}

let (t2, value2) = time(star2(debug: false))
print("star 2: \(value2) | \(t2 / 1000)µs")
