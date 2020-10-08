public extension String {
    func isANonce() -> Bool {
        let nonceRegularExpressionString = "\\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\\Z"
        let nonceRegex = try! NSRegularExpression.init(pattern: nonceRegularExpressionString, options: [])

        if nonceRegex.numberOfMatches(in: self, options: .anchored, range: NSMakeRange(0, self.count)) > 0 {
            return true
        }

        let tokenizerNonceRegularExpressionString = "\\Atokencc_[0-9a-z_]+\\Z"
        let tokenizerNonceRegex = try! NSRegularExpression.init(pattern: tokenizerNonceRegularExpressionString, options: [])

        return tokenizerNonceRegex.numberOfMatches(in: self, options: .anchored, range: NSMakeRange(0, self.count)) > 0
    }
}
