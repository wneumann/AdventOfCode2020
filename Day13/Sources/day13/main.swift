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

extension Int {
  func mod(_ other: Int) -> Int {
    guard other != 0 else { return 0 }
    let m = self % other
    return m < 0 ? m + other : m
  }
}

// MARK: - Real work happens here
let busIDs: [(Int, Int)] =
  zip(input[1].components(separatedBy: ","), 0...)
  .compactMap {
    guard let i = Int($0) else { return nil }
    return (i, $1) }
  .map { (m, v: Int) in (m, (-v).mod(m)) }
//print("busIDs: ", busIDs)

func findBestBus(arrivingAt time: Int, busIDs: [(Int, Int)]) -> (Int, Int) {
  busIDs.map { id in (-(time % id.0) + id.0, id.0) }.min(by: { $0.0 < $1.0 })!
}

func star1(_ input: [String]) -> Int {
  let time = Int(input[0])!
  let bestBus = findBestBus(arrivingAt: time, busIDs: busIDs)
//  print("The best bus is \(bestBus). The product is \(bestBus.0 * bestBus.1)")
  return bestBus.0 * bestBus.1
}

let (t1, value1) = time(star1(input))
print("star 1: \(value1) | \(t1 / 1000)µs")


// Knuth's modular inverse
func modInv(value: Int, modulus: Int) -> Int? {
  var inv = 1, gcd = value, v1 = 0, v3 = modulus
  var even = true
  while v3 != 0 {
    (inv, v1, gcd, v3) = (v1, inv + gcd / v3 * v1, v3, gcd % v3)
    even.toggle()
  }
  if gcd != 1 { return nil }
  return even ? inv : modulus - inv
}

func chineseRemainder(_ mas: [(Int, Int)]) -> Int {
  let mis = mas.map(\.0), m = mis.reduce(1, *)
  let ais = mas.map(\.1)
  let ws = mis.map { mi -> Int in
    let zi = m / mi
    guard let yi = modInv(value: zi, modulus: mi) else { fatalError("\(zi)^-1 mod \(mi) does not exist!") }
    return (yi * zi) % m
  }
  return zip(ws, ais).reduce(0, { ($0 + ($1.0 * $1.1)) % m })
}

let (t2, value2) = time(chineseRemainder(busIDs))
print("star 2: \(value2) | \(t2 / 1000)µs")

//print("Star2: \(chineseRemainder(busIDs))")

// MARK: - Run the code, report the result
//func star1(debug: Bool = false) -> Int {
//  let ferry = Ferry(input)
//  ferry.run(debug: debug)
//  return ferry.occupied
//}
//
//let (t1, value1) = time(star1(debug: false))
//print("star 1: \(value1) | \(t1 / 1000)µs")
//
//func star2(debug: Bool = false) -> Int {
//  let ferry = Ferry(input, tolerance: 5, visible: true)
//  ferry.run(debug: debug)
//  return ferry.occupied
//}
//
//let (t2, value2) = time(star2(debug: false))
//print("star 2: \(value2) | \(t2 / 1000)µs")
