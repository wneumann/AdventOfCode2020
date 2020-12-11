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

//extension Array where Element == State {
//  var snapshot: [String] { self.map(\.description) }
//}

let table = input.map { row in row.map(State.init) }
let mkStates = { () in Array(table.joined()) }
let rows = table.indices
let cols = table[0].indices

func getRC(_ l: Int) -> (Int, Int) {
  return(l / cols.count, l % cols.count)
}

func getNeighbors(of l: Int, in states: [State]) -> [State] {
  let (r,c) = getRC(l)
  let ns = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
    .map { (r + $0.0, c + $0.1) }
    .filter({ rows ~= $0.0 && cols ~= $0.1 })
    .map { cols.count * $0.0 + $0.1 }
  return ns.map { states[$0] }
}

func update(states: [State], tolerance: Int, gatherNeighbors: (Int, [State]) -> [State] = getNeighbors(of:in:)) -> [State] {
  states.enumerated().map { index, state -> State in
    let neighbors = gatherNeighbors(index, states)
    switch state {
    case .occupied: if neighbors.filter(\.isOccupied).count >= tolerance { return .empty }
    case .empty: if neighbors.allSatisfy(\.isEmpty) { return .occupied }
    case .floor: return .floor
    }
    return state
  }
}

//func printStates(_ states: [State]) {
//  var substates = states[...]
//  while !substates.isEmpty {
//    let line = substates.prefix(cols.count).map(\.description).joined()
//    print(line)
//    substates = substates.dropFirst(cols.count)
//  }
//  print("\n\n")
//}

func star1(_ states: [State]) -> Int {
  var states = states
  var cnt = 0
  var newStates = update(states: states, tolerance: 4)
  while newStates != states && cnt < 1000 {
    states = newStates
    newStates = update(states: states, tolerance: 4)
    cnt += 1
  }
  return states.filter(\.isOccupied).count
}

let (t1,floops) = time(star1(mkStates()))
print("***** star1: \(floops) | elapsed time: \(t1 / 1000)µs")

func getVisibleNeighbors(of l: Int, in states: [State]) -> [State] {
  let rc = getRC(l)
  func look(_ direction: (Int, Int)) -> State? {
    var (y, x) = direction, (r,c) = (rc.0+y, rc.1+x)
    while rows ~= r && cols ~= c {
      switch states[cols.count * r + c] {
      case .floor: (r, c) = (r+y, c+x)
      case let state: return state
      }
    }
    return nil
  }
  return [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)].compactMap(look)
}


func star2(_ states: [State]) -> Int {
  var states = states
  var cnt = 0
  var newStates = update(states: states, tolerance: 5, gatherNeighbors: getVisibleNeighbors(of:in:))
  while newStates != states && cnt < 1000 {
    states = newStates
    newStates = update(states: states, tolerance: 5, gatherNeighbors: getVisibleNeighbors(of:in:))
    cnt += 1
  }
  if cnt > 1000 { print("overlooped?") }
  return states.filter(\.isOccupied).count
}

let (t2,ploops) = time(star2(mkStates()))
print("***** star2: \(ploops) | elapsed time: \(t2 / 1000)µs")
