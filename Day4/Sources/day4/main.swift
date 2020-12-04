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

enum LengthUnit {
  case inch, centimeter
  
  init?(_ str: Substring) {
    switch str {
    case "in": self = .inch
    case "cm": self = .centimeter
    default: return nil
    }
  }
}

enum EyeColor {
  case amber, blue, brown, gray, green, hazel, other
  
  init?(_ str: String) {
    switch str {
    case "amb": self = .amber
    case "blu": self = .blue
    case "brn": self = .brown
    case "gry": self = .gray
    case "grn": self = .green
    case "hzl": self = .hazel
    case "oth": self = .other
    default: return nil
    }
  }
}

enum PassportField {
  case byr(Int)
  case iyr(Int)
  case eyr(Int)
  case hgt(Int, LengthUnit)
  case hcl(Int)
  case ecl(EyeColor)
  case pid(Int)
  case cid(String)
  
  init?(field: String, value: String) {
    switch field {
    case "byr":
      guard let birthYear = Int(value), 1920...2002 ~= birthYear else { return nil }
      self = .byr(birthYear)
    case "iyr":
      guard let issueYear = Int(value), 2010...2020 ~= issueYear else { return nil }
      self = .iyr(issueYear)
    case "eyr":
      guard let expirationYear = Int(value), 2020...2030 ~= expirationYear else { return nil }
      self = .eyr(expirationYear)
    case "hgt":
      guard
        let unit = LengthUnit(value.suffix(2)),
        let height = Int(value.dropLast(2)),
        (.centimeter ~= unit && 150...193 ~= height) || (.inch ~= unit && 59...76 ~= height)
      else { return nil }
      self = .hgt(height, unit)
    case "hcl":
      guard
        value.count == 7,
        value.first! == "#",
        let hairColor = Int(value.dropFirst(), radix: 16)
      else { return nil }
      self = .hcl(hairColor)
    case "ecl":
      guard let eyeColor = EyeColor(value) else { return nil }
      self = .ecl(eyeColor)
    case "pid":
      guard value.count == 9, let passportID = Int(value) else { return nil }
      self = .pid(passportID)
    case "cid":
      self = .cid(value)
    default: return nil
    }
  }
}

struct Passport {
  static func splitFields(_ record: String) -> [String: String]? {
    let fullPass = Set(["ecl", "pid", "eyr", "hcl", "byr", "iyr", "hgt"])
    let passport: [String: String] =
      record.components(separatedBy: .whitespacesAndNewlines).reduce(into: [:]) {
        let arr = $1.components(separatedBy: ":")
        $0[arr[0]] = arr[1]
      }
    
    return fullPass.intersection(passport.keys) == fullPass ? passport : nil
  }
  
  private var fields = [String: PassportField]()
  
  init?(_ str: String) {
    guard let fieldDict = Passport.splitFields(str) else { return nil }
    for (field, value) in fieldDict {
      guard let passportField = PassportField(field: field, value: value) else { return nil }
      fields[field] = passportField
    }
  }
}

let softValidPasses = input.compactMap(Passport.splitFields).count
print("There are \(softValidPasses) 'valid' passports.")
let hardValidPasses = input.compactMap(Passport.init)
print("There are \(hardValidPasses.count) truly valid passports.")
