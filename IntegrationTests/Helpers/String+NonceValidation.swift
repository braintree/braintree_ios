import Foundation

extension String {
    var isANonce: Bool {
        do {
            let noncePattern = "\\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\\Z"
            var regex = try NSRegularExpression(pattern: noncePattern)
            
            if regex.numberOfMatches(in: self, range: NSMakeRange(0, self.count)) > 0 {
                return true
            }
            
            let tokenizerNoncePattern = "\\Atokencc_[0-9a-z_]+\\Z"
            regex = try NSRegularExpression(pattern: tokenizerNoncePattern)
            
            return regex.numberOfMatches(in: self, range: NSMakeRange(0, self.count)) > 0
            
        } catch {
            NSLog("Error parsing regex: \(error.localizedDescription)")
            return false
        }
    }
}
