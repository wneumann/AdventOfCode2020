import ArgumentParser
import Foundation

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here
let input =
  try String(contentsOf: options.inURL, encoding: .utf8)
  .trimmingCharacters(in: .whitespacesAndNewlines)
  .components(separatedBy: "\n\n")

struct Passport {
//  let byr: String   // (Birth Year)
//  let cid: String?  // (Country ID)
//  let ecl: String   // (Eye Color)
//  let eyr: String   // (Expiration Year)
//  let hcl: String   // (Hair Color)
//  let hgt: String   // (Height)
//  let iyr: String   // (Issue Year)
//  let pid: String   // (Passport ID)
  
  let fields: [String: String]
  
  init?(_ str: String) {
    let fieldstr: [(String, String)] =
      str
        .components(separatedBy: .whitespacesAndNewlines)
        .map {
          let arr = $0.components(separatedBy: ":")
          return (arr[0], arr[1])
        }
    fields = Dictionary(uniqueKeysWithValues: fieldstr)
    print("input: \(str)\nfieldstr: \(fieldstr)\ndict: \(fields)\n\n")
    guard ["byr", "ecl", "eyr", "hcl", "hgt", "iyr", "pid"].compactMap({ fields[$0] }).count == 7 else { return nil }
    
  }
}

let validPasses = input.compactMap(Passport.init)
print("There are \(validPasses.count) 'valid' passports.")
