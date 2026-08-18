import UIKit
import BraintreeCore
import BraintreePayPal
import BraintreePayPalSavedPaymentMethod

class PayPalSavedPaymentMethodViewController: PaymentButtonBaseViewController {

    // Hardcoded sandbox client token for testing — it carries the `paymentMethodIdJwt` claim
    // needed for the sticky-FI fetch, which the demo's normal client-token flow doesn't produce.
    // swiftlint:disable:next line_length
    private let hardcodedClientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJleUpyYVdRaU9pSXlNREU0TURReU5qRTJMWE5oYm1SaWIzZ2lMQ0pwYzNNaU9pSm9kSFJ3Y3pvdkwyRndhUzV6WVc1a1ltOTRMbUp5WVdsdWRISmxaV2RoZEdWM1lYa3VZMjl0SWl3aVlXeG5Jam9pUlZNeU5UWWlmUS5leUpsZUhBaU9qRTNPRGN4TVRnMU1qVXNJbXAwYVNJNkltWTVNVGhoWVdObUxUaGpOek10TkRBd1lpMWlPVFE1TFRWbE9XTXlNVEl4TVdGa1lpSXNJbk4xWWlJNkluSXpibnAwTmpSamRtWTFlR3Q0Y25RaUxDSnBjM01pT2lKb2RIUndjem92TDJGd2FTNXpZVzVrWW05NExtSnlZV2x1ZEhKbFpXZGhkR1YzWVhrdVkyOXRJaXdpYldWeVkyaGhiblFpT25zaWNIVmliR2xqWDJsa0lqb2ljak51ZW5RMk5HTjJaalY0YTNoeWRDSXNJblpsY21sbWVWOWpZWEprWDJKNVgyUmxabUYxYkhRaU9tWmhiSE5sTENKMlpYSnBabmxmZDJGc2JHVjBYMko1WDJSbFptRjFiSFFpT21aaGJITmxmU3dpY21sbmFIUnpJanBiSW0xaGJtRm5aVjkyWVhWc2RDSmRMQ0p6WTI5d1pTSTZXeUpDY21GcGJuUnlaV1U2Vm1GMWJIUWlMQ0pDY21GcGJuUnlaV1U2UTJ4cFpXNTBVMFJMSWwwc0ltOXdkR2x2Ym5NaU9uc2ljR0Y1Y0dGc1gyTnNhV1Z1ZEY5cFpDSTZJa0ZVZFdrd01YSkhURlJVYTFkZlFXODJaMFpuWjBoR05YVTJkMXBmWnpKWVVteENiR2xMVTI5eldteElRWEY0ZDFWRFNuZ3RWVzkyTjFsSFJEQnFXWE5mUzJkSVQwTnNhR05IVEVJeWJubGFJbjE5LldJZmVhVGxMcG1fbHgyVFUtNjB1RGxxa1lkQzFzclJNVnF1Sm8yUG1OQkxRdTFHa1V4aWtMcWMzRTU0R1NBV2FqekUxMW0wWklOVm9aejZqeEJIS093IiwiY29uZmlnVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL3Izbnp0NjRjdmY1eGt4cnQvY2xpZW50X2FwaS92MS9jb25maWd1cmF0aW9uIiwiZ3JhcGhRTCI6eyJ1cmwiOiJodHRwczovL3BheW1lbnRzLnNhbmRib3guYnJhaW50cmVlLWFwaS5jb20vZ3JhcGhxbCIsImRhdGUiOiIyMDE4LTA1LTA4IiwiZmVhdHVyZXMiOlsidG9rZW5pemVfY3JlZGl0X2NhcmRzIl19LCJjbGllbnRBcGlVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvcjNuenQ2NGN2ZjV4a3hydC9jbGllbnRfYXBpIiwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwibWVyY2hhbnRJZCI6InIzbnp0NjRjdmY1eGt4cnQiLCJhc3NldHNVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbSIsImF1dGhVcmwiOiJodHRwczovL2F1dGgudmVubW8uc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbSIsInZlbm1vIjoib2ZmIiwiY2hhbGxlbmdlcyI6W10sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsImFuYWx5dGljcyI6eyJ1cmwiOiJodHRwczovL29yaWdpbi1hbmFseXRpY3Mtc2FuZC5zYW5kYm94LmJyYWludHJlZS1hcGkuY29tL3Izbnp0NjRjdmY1eGt4cnQifSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImJpbGxpbmdBZ3JlZW1lbnRzRW5hYmxlZCI6dHJ1ZSwiZW52aXJvbm1lbnROb05ldHdvcmsiOmZhbHNlLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYWxsb3dIdHRwIjp0cnVlLCJkaXNwbGF5TmFtZSI6IlBheVBhbCIsImNsaWVudElkIjoiQVR1aTAxckdMVFRrV19BbzZnRmdnSEY1dTZ3Wl9nMlhSbEJsaUtTb3NabEhBcXh3VUNKeC1Vb3Y3WUdEMGpZc19LZ0hPQ2xoY0dMQjJueVoiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJicmFpbnRyZWVDbGllbnRJZCI6Im1hc3RlcmNsaWVudDMiLCJtZXJjaGFudEFjY291bnRJZCI6InBheXBhbCIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJwYXltZW50TWV0aG9kSWRKd3QiOiJleUpoYkdjaU9pSkZVekkxTmlJc0ltdHBaQ0k2SW1KMExYTmhibVF0Y0hKbFpuQnRMVGRoWlRVeE5tWWlmUS5leUpxZEdraU9pSmtaVEV6WmpsbFpTMWxaVEV3TFRRek5HSXRZV1UxTVMxaU1qUmxaRGhpT0dRek1Ea2lMQ0pwYzNNaU9pSm9kSFJ3Y3pvdkwzQmhlVzFsYm5SekxuTmhibVJpYjNndVluSmhhVzUwY21WbExXRndhUzVqYjIwaUxDSnpkV0lpT2lKeU0yNTZkRFkwWTNabU5YaHJlSEowSWl3aVpYaHdJam94TnpnM01URTROVEkwTENKd2JXbGtJam9pYm5ZeWJuRjJhak1pZlEuZnNqUHJZV195V2YzdzdTX2Fvc1RwTzVyWUd5MFR4ekRVRWpsMl9UOWZTcWh3VkNHcFhoTzlUT3VYZjJjWDFkZlN3XzFydGZmZUREdTExMFVYTm5yQXcifQ=="

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PayPal Saved Payment Method"

        // swiftlint:disable:next force_unwrapping
        let universalLink = URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!
        let request = BTPayPalCheckoutRequest(amount: "10.00", enablePayPalAppSwitch: true)

        embed(
            BTPayPalSavedPaymentMethodView(
                amount: "10.00",
                authorization: hardcodedClientToken,
                universalLink: universalLink,
                fallbackURLScheme: "com.braintreepayments.Demo.payments",
                request: request,
                completion: { [weak self] nonce, error in
                    guard let self else { return }
                    if let error {
                        self.progressBlock(error.localizedDescription)
                        return
                    }
                    self.completionBlock(nonce)
                }
            )
        )
    }

    override func createPaymentButton() -> UIView {
        let placeholderView = UIView()
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        return placeholderView
    }
}
