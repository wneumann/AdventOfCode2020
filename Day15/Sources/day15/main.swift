import Foundation

// MARK: - Utilty crud
func time<Res>(_ proc: @autoclosure () -> Res) -> (UInt64, Res) {
  let startTime = DispatchTime.now().uptimeNanoseconds
  let star = proc()
  let elapsedTime = DispatchTime.now().uptimeNanoseconds - startTime
  return (elapsedTime, star)
}


// MARK: - Real work happens here
func vanEck(_ input: [Int], _ target: Int) -> Int {
  var gameDict = Dictionary(uniqueKeysWithValues: zip(input.dropLast(), 1...)),
      nextNum = input.last!
  for count in input.count ..< target {
    let lastNum = count - gameDict[nextNum, default: count]
    gameDict[nextNum] = count
    nextNum = lastNum
  }
  return nextNum
}

// MARK: - Run the code, report the result
 let (t1, star1) = time(vanEck([16,11,15,0,1,7], 2020))
 print("star 1: \(star1) | \(t1 / 1000)µs")
 
 let (t2, star2) = time(vanEck([16,11,15,0,1,7], 30000000))
 print("star 2: \(star2) | \(t2 / 1000)µs")
