import Foundation

public extension String {

    func matches(_ regex: String) -> Bool {
        self.range(of: regex, options: .regularExpression) != nil
    }
}
