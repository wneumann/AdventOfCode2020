import ArgumentParser
import Foundation

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here
let passwordParser =
  zip(.keep(.int, discard: .char),
      .keep(.int, discard: .whitespace),
      .keep(.char, discard: .literal(": ")),
      .remainder)
  

@available(OSX 10.15, *)
extension String {
  func passwordComponents() -> (Int, Int, Character, String)? {
    return try? passwordParser.run(self).match.get()
  }
  
  var isValidPassword: Bool {
    guard let (lowerBound, upperBound, requiredCharacter, password) = self.passwordComponents() else { return false }
    return lowerBound...upperBound ~= password.filter { $0 == requiredCharacter }.count
  }
  
  var isReallyValidPassword: Bool {
    guard let (firstOffset, secondOffset, comparisonCharacter, password) = self.passwordComponents() else { return false }
    guard let firstCharacter = password.dropFirst(firstOffset - 1).first else { return false }
    guard let secondCharacter = password.dropFirst(secondOffset - 1).first else { return false }
    return (firstCharacter == comparisonCharacter) != (secondCharacter == comparisonCharacter)
  }
}

let passwords =
  try String(contentsOf: options.inURL, encoding: .utf8)
        .components(separatedBy: .newlines)


if #available(OSX 10.15, *) {
  let valids = passwords.filter(\.isValidPassword).count
  print("There are \(valids) valid passwords in the database")
  let reallyValids = passwords.filter(\.isReallyValidPassword).count
  print("There are \(reallyValids) valid passwords in the database")
} else {
  print("Update your damn OS already!")
}
