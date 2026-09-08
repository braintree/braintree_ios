import Foundation

class Helpers: NSObject {

    static let shared = Helpers()

    /// The live sandbox demo merchant server used to fetch a fresh client token at test run time.
    /// Kept in sync with `BraintreeDemoSettings.currentEnvironmentURLString` (Demo target) — update both if this changes.
    static let demoMerchantURLString = "https://braintree-demo-merchant-63b7a2204f6e.herokuapp.com/"

    func futureYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: Date())
    }

    /// Fetches a fresh, short-lived client token from the live sandbox demo merchant server.
    /// Client tokens expire after 24 hours, so tests that specifically exercise client-token
    /// auth must request one at run time rather than relying on a hardcoded fixture.
    func fetchClientToken() async throws -> String {
        guard let url = URL(string: "\(Helpers.demoMerchantURLString)client_token") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(ClientTokenFetchResponse.self, from: data).clientToken
    }
}

private struct ClientTokenFetchResponse: Decodable {

    let clientToken: String
}
