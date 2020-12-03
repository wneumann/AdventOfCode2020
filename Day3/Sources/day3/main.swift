import ArgumentParser
import Foundation

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL

  @Flag var skipStar1 = false
  @Flag var skipStar2 = false
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here
let input = try String(contentsOf: options.inURL, encoding: .utf8)
