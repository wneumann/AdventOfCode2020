import Foundation

// MARK: - Utilty crud
func time<Res>(_ proc: @autoclosure () -> Res) -> (UInt64, Res) {
  let startTime = DispatchTime.now().uptimeNanoseconds
  let star = proc()
  let elapsedTime = DispatchTime.now().uptimeNanoseconds - startTime
  return (elapsedTime, star)
}

let player1input = [41, 48, 12, 6, 1, 25, 47, 43, 4, 35, 10, 13, 23, 39, 22, 28, 44, 42, 32, 31, 24, 50, 34, 29, 14]
let player2input = [36, 49, 11, 16, 20, 17, 26, 30, 18, 5, 2, 38, 7, 27, 21, 9, 19, 15, 8, 45, 37, 40, 33, 46, 3]

// MARK: - Real work happens here
struct Queue<T: Hashable>: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(self.reversed())
  }
  
  var head: Array<T>
  var tail: Array<T>
  
  init<S: Sequence>(_ inp: S) where S.Element == T {
    tail = Array(inp)
    head = []
  }
  
  mutating func enqueue(_ item: T) {
    tail.append(item)
  }
  
  mutating func enqueue(_ items: [T]) {
    tail.append(contentsOf: items)
  }
  
  mutating func dequeue() -> T? {
    if head.isEmpty {
      head.append(contentsOf: tail.reversed())
      tail.removeAll()
    }
    return head.popLast()
  }
  
  func prefix(_ k: Int) -> ArraySlice<T> {
    return head.count >= k ? head.reversed().prefix(k): (head.reversed() + tail).prefix(k)
  }
  
  func reversed() -> [T] {
    return tail.reversed() + head
  }
  
  func queue() -> [T] {
    return head.reversed() + tail
  }

  var isEmpty: Bool { head.isEmpty && tail.isEmpty }
  var count: Int { head.count + tail.count }
}

func star1(player1cards: [Int], player2cards: [Int]) -> Int {
  var player1 = Queue(player1cards), player2 = Queue(player2cards)
  while !player1.isEmpty && !player2.isEmpty {
    let card1 = player1.dequeue()!, card2 = player2.dequeue()!
    if card1 > card2 {
      player1.enqueue([card1, card2])
    } else {
      player2.enqueue([card2, card1])
    }
  }
  let cards = player1.isEmpty ? player2 : player1
//  print("winning deck: \(cards.reversed())")
  return zip(cards.reversed(), 1...).reduce(0) { b,v in b + v.0 * v.1 }
}


func star2(player1cards: [Int], player2cards: [Int]) -> Int {
  let player1 = Queue(player1cards), player2 = Queue(player2cards)
  func game(player1: Queue<Int>, player2: Queue<Int>, seen: Set<[Int]>, gameNo: Int = 1) -> ([Int], [Int]) {
    var player1 = player1, player2 = player2, seen = seen, round = 0
    
    while !player1.isEmpty && !player2.isEmpty {
      round += 1
      guard !seen.contains([player1.hashValue, player2.hashValue]) else { return (player1.reversed(), []) }
      seen.insert([player1.hashValue, player2.hashValue])
      let card1 = player1.dequeue()!, card2 = player2.dequeue()!
      if player1.count >= card1 && player2.count >= card2 {
        let (p1, _): ([Int], [Int]) =
          game(player1: Queue(player1.prefix(card1)), player2: Queue(player2.prefix(card2)), seen: Set<[Int]>(), gameNo: gameNo + 1)
        if p1.isEmpty {
          player2.enqueue([card2, card1])
        } else {
          player1.enqueue([card1, card2])
        }
      } else {
        if card1 > card2 {
          player1.enqueue([card1, card2])
        } else {
          player2.enqueue([card2, card1])
        }
      }
    }
    return (player1.reversed(), player2.reversed())
  }
  let (p1, p2) = game(player1: player1, player2: player2, seen: Set<[Int]>())
  let cards = p1.isEmpty ? p2 : p1
  print("winning deck: \(cards.reversed())")
  return zip(cards, 1...).reduce(0) { b,v in b + v.0 * v.1 }
}

// MARK: - Run the code, report the result
let (t1, value1) = time(star1(player1cards: player1input, player2cards: player2input))
print("star 1: \(value1) | \(t1 / 1000)µs")

let (t2, value2) = time(star2(player1cards: player1input, player2cards: player2input))
print("star 2: \(value2) | \(t2 / 1000)µs")

