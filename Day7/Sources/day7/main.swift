import Foundation

let rules =
  try String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]), encoding: .utf8)
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: "\n")

func ruleParse(_ rule: String) -> (container: String, contains: [(String, Int)]) {
  let parserX: Parser<[(String, Int)]> =
    .choose(
      Parser.string("no other bags").map { _ in [(String, Int)]() },
      Parser.star(
        zip(with: { ($1, $0) },
          .int,
          Parser.trim(
            Parser.star(
              Parser.char,
              until: .choose(Parser<Void>.literal(" bags"), Parser<Void>.literal(" bag"))
            ),
            where: { $0.isWhitespace || $0.isPunctuation }).map{ String($0) })))

  let split = rule.components(separatedBy: " bags contain ")
  
  return (container: split[0], contains: try! parserX.run(split[1]).match.get())
}

let parsedRules = rules.map(ruleParse)

var flow = [String: (containedIn: Set<String>, contains: [String: Int])]()
for (container, contains) in parsedRules {
  let record = flow[container, default: (containedIn: [], contains: [:])]
  flow[container] = (containedIn: record.containedIn, contains: Dictionary(uniqueKeysWithValues: contains))
  for (containee,_) in contains {
    let containeeRecord = flow[containee, default: (containedIn: [], contains: [:])]
    flow[containee] = (containedIn: containeeRecord.containedIn.union([container]) , contains: containeeRecord.contains)
  }
}

func findContainerFamily(_ bag: String) -> Set<String> {
  guard let fam = flow[bag]?.containedIn else { return [] }
  return fam.map(findContainerFamily).reduce(fam, { $0.union($1) } )
}

let shinyFamily = findContainerFamily("shiny gold")
print("There are \(shinyFamily.count) different bags that can contain a shiny gold bag.")

func findFullCount(_ bag: String, depth: Int = 0) -> Int {
  guard let contents = flow[bag]?.contains, !contents.isEmpty else { return 1 }
  return contents
    .map { (subBag, count) in count * findFullCount(subBag, depth: depth+1) }
    .reduce(1, +)
}

let shinyContents = findFullCount("shiny gold", depth: 0) - 1
print("There are \(shinyContents) bags inside 1 shiny gold bag.")
