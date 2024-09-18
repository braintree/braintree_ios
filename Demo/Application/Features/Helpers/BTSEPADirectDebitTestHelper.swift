import Foundation

/// Provides helper functions to test the SEPA Direct Debit flow in sandbox.
enum BTSEPADirectDebitTestHelper {

    /// Generates a valid 27-digit IBAN (International Bank Account Number) for testing SEPA Direct Debit flows.
    /// - Returns: a valid IBAN
    static func generateValidSandboxIBAN() -> String {
        let countryCode: String = "FR"
        let bankCode: String = "30006"
        let branchCode: String = "00001"
        let accountNumber = Int.random(in: 10_000_000_000...100_000_000_000)

        let accountNumberWithChecksum = accountNumberWithChecksum(
            bankCode: Int(bankCode) ?? 0,
            branchCode: Int(branchCode) ?? 0,
            accountNumber: accountNumber
        )
        let checksum = checksum(bankCode: bankCode, branchCode: branchCode, accountNumber: Int(accountNumberWithChecksum) ?? 0)

        return countryCode + "\(checksum)\(bankCode)\(branchCode)\(accountNumberWithChecksum)"
    }

    private static func accountNumberWithChecksum(bankCode: Int, branchCode: Int, accountNumber: Int) -> String {
        let sum: Int = 89 * bankCode + 15 * branchCode + 3 * accountNumber
        let checksum = 97 - calculateMod97(from: sum)

        return "\(accountNumber)\(checksum)"
    }

    private static func checksum(bankCode: String, branchCode: String, accountNumber: Int) -> String {
        // 152700 is taken from the conversion table here: https://community.appway.com/screen/kb/article/generating-and-validating-an-iban-1683400256881#conversion-table
        // and is representative of the characters "FR" with 00 being added to the end for all bban's to calculate the checksum
        let bbanString: String = bankCode + branchCode + "\(accountNumber)" + "152700"
        let modResult = (Decimal(string: bbanString) ?? 0) % 97
        let result = 98 - modResult
        return "\(result)"
    }

    private static func calculateMod97(from accountNumber: Int) -> Int {
        var mod: Int = 0
        let accountNumberArray = String(accountNumber).map { String($0) }

        for digit in accountNumberArray {
            mod = ((mod * 10) + (Int(digit) ?? 0)) % 97
        }

        return mod
    }
}

// We need this to calculate the mod result on a large integer since Int cannot handle the calculation of an number of this size
private extension Decimal {

    // Allows us to divide by a large integer for use in calculating a checksum
    static func % (lhs: Decimal, rhs: Decimal) -> Decimal {
        precondition(lhs > 0 && rhs > 0)

        if lhs < rhs {
            return lhs
        } else if lhs == rhs {
            return 0
        }

        var quotient = lhs / rhs
        var rounded = Decimal()
        NSDecimalRound(&rounded, &quotient, 0, .down)

        return lhs - (rounded * rhs)
    }
}
