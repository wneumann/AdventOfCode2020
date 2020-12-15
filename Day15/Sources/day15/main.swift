import Foundation

// MARK: - Utilty crud
func time<Res>(_ proc: @autoclosure () -> Res) -> (UInt64, Res) {
  let startTime = DispatchTime.now().uptimeNanoseconds
  let star = proc()
  let elapsedTime = DispatchTime.now().uptimeNanoseconds - startTime
  return (elapsedTime, star)
}


// MARK: - Real work happens here
func star1(_ input: [Int], _ target: Int) -> Int {
  var gameDict = Dictionary(uniqueKeysWithValues: zip(input.dropLast(), 1...)),
      nextNum = input.last!,
      count = input.count
  while count < target {
    let lastNum = count - gameDict[nextNum, default: count]
    gameDict[nextNum] = count
    nextNum = lastNum
    count += 1
  }
  return nextNum
}

// MARK: - Run the code, report the result
 let (t1, value1) = time(star1([16,11,15,0,1,7], 2020))
 print("star 1: \(value1) | \(t1 / 1000)µs")
 
 let (t2, value2) = time(star1([16,11,15,0,1,7], 30000000))
 print("star 2: \(value2) | \(t2 / 1000)µs")
