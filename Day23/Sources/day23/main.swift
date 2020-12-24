import Foundation

// MARK: - Utilty crud
func time<Res>(_ proc: @autoclosure () -> Res) -> (UInt64, Res) {
  let startTime = DispatchTime.now().uptimeNanoseconds
  let star = proc()
  let elapsedTime = DispatchTime.now().uptimeNanoseconds - startTime
  return (elapsedTime, star)
}

let exInput = [3, 8, 9, 1, 2, 5, 4, 6, 7]
let input =   [8, 7, 1, 3, 6, 9, 4, 5, 2]

// MARK: - Real work happens here
class Node: CustomStringConvertible {
  let value: Int
  var next: Node?
  var prev: Node?
  
  var next3: Node? { next?.next?.next }
  var description: String { "\(prev?.value ?? 0) <- (\(value)) -> \(next?.value ?? 0)" }
  
  init(_ v: Int, next: Node? = nil, prev: Node? = nil) {
    value = v
    self.next = next
    self.prev = prev
  }
  
  func cut() -> Node {
    if let p = prev { p.next = next }
    if let n = next { n.prev = prev }
    next = nil
    prev = nil
    return self
  }
  
  func cut3() -> (Node, Node) { // not particularly safe as written
    let start = next!, end = start.next!.next!, restart = end.next!
    restart.prev = self
    next = restart
    end.next = nil
    start.prev = nil
    return (start, end)
  }
  
  func insert(snippet: (Node, Node)) {
    let (a, b) = snippet
    a.prev = self
    b.next = next
    next!.prev = b
    next = a
  }
  
  func find(_ v: Int) -> Node? {
    if value == v { return self }
    var nxt = next
    while nxt != nil && nxt !== self {
      if nxt!.value == v { return nxt }
      nxt = nxt!.next
    }
    return nil
  }
  
  func print() {
    var nxt = next, values = ["(\(value))"]
    while nxt != nil && nxt !== self {
      values.append("\(nxt!.value)")
      nxt = nxt!.next
    }
    Swift.print(values.joined(separator: " -> "))
  }
  
  func walk() -> [Int] {
    var nxt = next, values = [value]
    while nxt != nil && nxt !== self {
      values.append(nxt!.value)
      nxt = nxt!.next
    }
    return values
  }
}

func shuffle(current: Node) -> Node {
  let (a, b) = current.cut3()
  
  var dVal = current.value
  for _ in 1...4 {
    dVal -= 1
    if dVal < 1 { dVal = 9 }
    if a.find(dVal) == nil { break } // else { print("-- not dVal: \(dVal)") }
  }
  guard let destination = current.find(dVal) else { current.print(); fatalError("Dunno?") }
  destination.insert(snippet: (a, b))
  return current.next!
}

// MARK: - Run the code, report the result
func star1(_ input: [Int], rounds: Int) -> String {
  let head = Node(input.first!, next: nil, prev: nil)
  let tail = input.dropFirst().reduce(head) { b, v in
    let node = Node(v, next: nil, prev: b)
    b.next = node
    return node
  }
  head.prev = tail
  tail.next = head

  var current = head
  for _ in 1...rounds {
    current = shuffle(current: current)
  }
  return current.find(1)!.walk().dropFirst().map(String.init).joined()
}

func star2(_ input: [Int], rounds: Int, numCups: Int) -> Int {
  let head = Node(input.first!)
  let tail = (input.dropFirst() + (10...numCups)).reduce(head) { b, v in
    let node = Node(v)
    node.prev = b
    b.next = node
    return node
  }
  head.prev = tail
  tail.next = head

  var bigMap = Array(repeating: head, count: 10), idx = 1, current = head
  while idx < 10 {
    bigMap[current.value] = current
    current = current.next!
    idx += 1
  }
  while idx <= numCups {
    bigMap.append(current)
    current = current.next!
    idx += 1
  }
  
  func shuffle(current: Node, round: Int) -> Node {
    let (a, b) = current.cut3()
    var dVal = current.value
    for _ in 1...4 {
      dVal -= 1
      if dVal < 1 { dVal = numCups }
      if a.find(dVal) == nil { break }
    }
    let destination = bigMap[dVal]
    guard destination.value == dVal else { fatalError("**** Round \(round) bigMap[\(dVal)]: \(destination)") }
    destination.insert(snippet: (a, b))
    return current.next!
  }
  
  current = bigMap[0]
  for round in 1...rounds {
    current = shuffle(current: current, round: round)
  }
  let one = bigMap[1]
  return one.next!.value * one.next!.next!.value
}

let (t1, value1) = time(star1(input, rounds: 10))
print("star 1: \(value1) | \(t1 / 1000)µs")

let (t2, value2) = time(star2(input, rounds: 10_000_000, numCups: 1_000_000))
print("star 2: \(value2) | \(t2 / 1000)µs")
