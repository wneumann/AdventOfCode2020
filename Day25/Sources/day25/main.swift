import Foundation

// MARK: - Utilty crud
func time<Res>(_ proc: @autoclosure () -> Res) -> (UInt64, Res) {
  let startTime = DispatchTime.now().uptimeNanoseconds
  let star = proc()
  let elapsedTime = DispatchTime.now().uptimeNanoseconds - startTime
  return (elapsedTime, star)
}

let modulus = 20201227
let gx = 9232416
let gy = 14144084

let exgx = 17807724
let exgy = 5764801

// MARK: - Real work happens here

func exp(_ base: Int, _ e: Int, _ modulus: Int) -> Int {
  (0..<e).reduce(1) { b, _ in (b * base) % modulus }
}

// MARK: - Run the code, report the result
func star1(_ target: Int, _ pk: Int) -> Int {
  var v = 1, x = 0
  while v != target {
    v = (v * 7) % modulus
    x += 1
  }
  print("x: \(x), 7^x mod \(modulus): \(exp(7, x, modulus))")
  let key = exp(pk, x, modulus)
  return key
}

let (t1, value1) = time(star1(gx, gy))
print("star 1: \(value1) | \(t1 / 1000)µs")

//let (t2, value2) = time(star2(input, rounds: 10_000_000, numCups: 1_000_000))
//print("star 2: \(value2) | \(t2 / 1000)µs")
