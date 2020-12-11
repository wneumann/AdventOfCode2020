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
  
  func prepareForUpdate() {
    guard state != .floor else { return }
    let neighborhood = neighbors.map(\.state)
    switch state {
    case .occupied: if neighborhood.filter(\.isOccupied).count >= tolerance { next = .empty }
    case .empty: if neighborhood.allSatisfy(\.isEmpty) { next = .occupied }
    case .floor: return
    }
  }
  
  func update() {
    state = next
  }
}

struct Ferry: CustomStringConvertible {
  var cells: [Cell]
  private var rows: Range<Int>
  private var cols: Range<Int>
  private let tolerance: Int
  var description: String {
    var subcells = cells[...], res = ""
    while !subcells.isEmpty {
      res += subcells.prefix(cols.count).map(\.description).joined()
      res += "\n"
      subcells.removeFirst(cols.count)
    }
    return res + "\n"
  }
  var occupied: Int { cells.filter { $0.state.isOccupied }.count }
  
  init(_ input: [String], tolerance: Int = 4, visible: Bool = false) { //, gatherNeighbors: (Int, Int, [Cell]) -> [Cell]) {
    let table = input.map { row in row.map { Cell($0, tolerance: tolerance) } }
    cells = Array(table.joined())
    rows = table.indices
    cols = table[0].indices
    self.tolerance = tolerance
    
    for (index, cell) in cells.enumerated() {
      cell.neighbors = visible ? getVisibleNeighbors(of: index) : getNeighbors(of: index)
    }
  }
  
  private func getNeighbors(of l: Int) -> [Cell] {
    let (r,c) = (l / cols.count, l % cols.count)
    let ns = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
      .map { (r + $0.0, c + $0.1) }
      .filter({ rows ~= $0.0 && cols ~= $0.1 })
      .map { cols.count * $0.0 + $0.1 }
    return ns.map { cells[$0] }
  }

  private func getVisibleNeighbors(of l: Int) -> [Cell] {
    let (r,c) = (l / cols.count, l % cols.count)
    func look(_ direction: (Int, Int)) -> Cell? {
      var (y, x) = direction, (r,c) = (r+y, c+x)
      while rows ~= r && cols ~= c {
        let cell = cells[cols.count * r + c]
        if cell.state != .floor { return cell }
        (r, c) = (r+y, c+x)
      }
      return nil
    }
    return [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)].compactMap(look)
  }

  @discardableResult func update() -> Bool {
    cells.forEach{ $0.prepareForUpdate() }
    if cells.allSatisfy(\.isSteadyState) {
      return false
    } else {
      cells.forEach { $0.update() }
      return true
    }
  }
  
  func run(debug: Bool = false) {
    if debug { print(description) }
    var safety = 0, stillEvolving: Bool
    repeat {
      stillEvolving = update()
      safety += 1
    } while stillEvolving && safety < 1000
  }
}

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
print("star 1: \(value2) | \(t2 / 1000)µs")
