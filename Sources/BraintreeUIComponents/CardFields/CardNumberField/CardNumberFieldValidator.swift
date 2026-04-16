import Foundation

struct CardNumberFieldValidator: CardFieldsValidatorProtocol {

    // MARK: - CardFieldValidatorProtocol Conformance

    func validate(_ value: String) -> ValidationResult {
        let digits = value.filter { $0.isNumber }

        guard !digits.isEmpty else {
            return .invalid("Card number is required")
        }

        let invalidCharacters = value.filter { !$0.isNumber && $0 != " " }
        guard invalidCharacters.isEmpty else {
            return .invalid("Card number is invalid")
        }

        let brand = detectBrand(from: digits)

        guard digits.count >= brand.minLength else {
            return .validating
        }

        guard digits.count <= brand.maxLength else {
            return .invalid("Card number is invalid")
        }

        guard brand.validLengths.contains(digits.count) else {
            return .invalid("Card number is invalid")
        }

        guard isLuhnValid(digits) else {
            return .invalid("Card number is invalid")
        }

        return .valid
    }

    // MARK: - Brand Detection

    func detectBrand(from digits: String) -> CardBrand {
        // Pass 1: strict prefixes
        for brand in CardBrand.allCases {
            for pattern in brand.prefixPatterns where digits.prefixMatch(of: pattern) != nil {
                return brand
            }
        }

        // Pass 2: relaxed prefixes
        for brand in CardBrand.allCases {
            for pattern in brand.relaxedPrefixPatterns where digits.prefixMatch(of: pattern) != nil {
                return brand
            }
        }

        return .unknown
    }

    /// Luhn algorithm - Processes digits right to left, doubling every second digit.
    private func isLuhnValid(_ digits: String) -> Bool {
        let numbers = digits.compactMap { $0.wholeNumberValue }
        var isOdd = true
        var oddSum = 0
        var evenSum = 0

        for digit in numbers.reversed() {
            if isOdd {
                oddSum += digit
            } else {
                evenSum += digit / 5 + (2 * digit) % 10
            }
            isOdd.toggle()
        }

        return (oddSum + evenSum) % 10 == 0
    }
}
