import Foundation

struct CardNumberFieldValidator: CardFieldsValidatorProtocol {

    // MARK: - CardFieldValidatorProtocol Conformance

    func validate(_ value: String) -> ValidationResult {
        let digits = value.filter { $0.isNumber }

        guard !digits.isEmpty else {
            return .invalid("Card number is required")
        }

        guard value.filter({ !$0.isNumber && $0 != " " }).isEmpty else {
            return .invalid("Card number is invalid")
        }

        let brand = detectBrand(from: digits)

        guard digits.count >= brand.minLength else {
            return .valid
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
            for pattern in brand.prefixPatterns {
                if matches(pattern: pattern, input: digits) {
                    return brand
                }
            }
        }

        // Pass 2: relaxed prefixes
        for brand in CardBrand.allCases {
            for pattern in brand.relaxedPrefixPatterns {
                if matches(pattern: pattern, input: digits) {
                    return brand
                }
            }
        }

        return .unknown
    }

    // MARK: - Private

    private func matches(pattern: String, input: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(input.startIndex..., in: input)
        return regex.firstMatch(in: input, range: range) != nil
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
