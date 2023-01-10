import Foundation

extension String {
  public func capturedGroups(withRegex regex: NSRegularExpression) -> [String] {
    var results = [String]()

    if let match = regex.firstMatch(
      in: self,
      range: NSRange(self.startIndex..., in: self))
    {
      let lastRangeIndex = match.numberOfRanges - 1
      guard lastRangeIndex >= 1 else { return results }

      for i in 1...lastRangeIndex {
        let capturedGroupIndex = match.range(at: i)
        let matchedString = (self as NSString).substring(with: capturedGroupIndex)
        results.append(matchedString)
      }
    }

    return results
  }
}
