import ArgumentParser
import Foundation

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL

//  @Flag var skipPair = false
//  @Flag var skipTriple = false
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here
extension String {
  var isValidPassword: Bool {
    let charactersToBeSkipped = CharacterSet(charactersIn: " -:")
    let scanner = Scanner(string: self)
    guard let lowerBound = scanner.scanInt() else { return false }
    _ = scanner.scanCharacters(from: charactersToBeSkipped)
    guard let upperBound = scanner.scanInt(), upperBound >= lowerBound else { return false }
    _ = scanner.scanCharacters(from: charactersToBeSkipped)
    guard let requiredCharacter = scanner.scanCharacter() else { return false }
    _ = scanner.scanCharacters(from: charactersToBeSkipped)
    guard let password = scanner.scanUpToCharacters(from: charactersToBeSkipped) else { return false }
    return lowerBound...upperBound ~= password.filter { $0 == requiredCharacter }.count
  }
}

let passwords =
  try String(contentsOf: options.inURL, encoding: .utf8)
        .components(separatedBy: .newlines).compactMap(Int.init)[...]


let valids = passwords.filter(\.isValidPassword).count
print("There are \() valid passwords in the database")
