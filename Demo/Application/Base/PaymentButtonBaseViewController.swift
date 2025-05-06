import UIKit
import BraintreeCore

let aauthorization = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJleUowZVhBaU9pSktWMVFpTENKaGJHY2lPaUpGVXpJMU5pSXNJbXRwWkNJNklqSXdNVGd3TkRJMk1UWXRjSEp2WkhWamRHbHZiaUlzSW1semN5STZJbWgwZEhCek9pOHZZWEJwTG1KeVlXbHVkSEpsWldkaGRHVjNZWGt1WTI5dEluMC5leUpsZUhBaU9qRTNORFkyTXpjMk1UWXNJbXAwYVNJNklqRXhOMlZqWXpBNExXWTBNVGt0TkRFNU1pMWhaV1JrTFRnd1ltSmlaVEZqT1dSa1lpSXNJbk4xWWlJNkltUm1lVFExYW1ScU0yUjRhMjE2TlcwaUxDSnBjM01pT2lKb2RIUndjem92TDJGd2FTNWljbUZwYm5SeVpXVm5ZWFJsZDJGNUxtTnZiU0lzSW0xbGNtTm9ZVzUwSWpwN0luQjFZbXhwWTE5cFpDSTZJbVJtZVRRMWFtUnFNMlI0YTIxNk5XMGlMQ0oyWlhKcFpubGZZMkZ5WkY5aWVWOWtaV1poZFd4MElqcG1ZV3h6Wlgwc0luSnBaMmgwY3lJNld5SnRZVzVoWjJWZmRtRjFiSFFpWFN3aWMyTnZjR1VpT2xzaVFuSmhhVzUwY21WbE9sWmhkV3gwSWl3aVFuSmhhVzUwY21WbE9rRllUeUlzSWtKeVlXbHVkSEpsWlRwUVlYbHRaVzUwYzFKbFlXUjVJbDBzSW05d2RHbHZibk1pT25zaVkzVnpkRzl0WlhKZmFXUWlPaUk0TlRrMVJETTVRaTB4TWpBeExUUTBORGN0UWtJNE15MDBSRGt5T0VaQ09EVTNSRElpZlgwLmEzRjU2X1FjUVR2QVRiTFZQNTduZC1IcEZMbTczZnNPRFJ6SjdxZ0twakJ6Umxqa1Qzd1lpbVVyRkRBWjF0eHVPOW1sdlhRc2RTRjZONU16VGlrYlRRP2N1c3RvbWVyX2lkPSIsImNvbmZpZ1VybCI6Imh0dHBzOi8vYXBpLmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGZ5NDVqZGozZHhrbXo1bS9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJncmFwaFFMIjp7InVybCI6Imh0dHBzOi8vcGF5bWVudHMuYnJhaW50cmVlLWFwaS5jb20vZ3JhcGhxbCIsImRhdGUiOiIyMDE4LTA1LTA4IiwiZmVhdHVyZXMiOlsidG9rZW5pemVfY3JlZGl0X2NhcmRzIl19LCJoYXNDdXN0b21lciI6dHJ1ZSwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuYnJhaW50cmVlZ2F0ZXdheS5jb206NDQzL21lcmNoYW50cy9kZnk0NWpkajNkeGttejVtL2NsaWVudF9hcGkiLCJlbnZpcm9ubWVudCI6InByb2R1Y3Rpb24iLCJtZXJjaGFudElkIjoiZGZ5NDVqZGozZHhrbXo1bSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5jb20iLCJ2ZW5tbyI6InByb2R1Y3Rpb24iLCJjaGFsbGVuZ2VzIjpbXSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6ZmFsc2UsImFuYWx5dGljcyI6eyJ1cmwiOiJodHRwczovL2NsaWVudC1hbmFseXRpY3MuYnJhaW50cmVlZ2F0ZXdheS5jb20vZGZ5NDVqZGozZHhrbXo1bSJ9LCJhcHBsZVBheSI6eyJjb3VudHJ5Q29kZSI6IlVTIiwiY3VycmVuY3lDb2RlIjoiVVNEIiwibWVyY2hhbnRJZGVudGlmaWVyIjoibWVyY2hhbnQuY29tLmJyYWludHJlZXBheW1lbnRzLnJpY2hhcmQiLCJzdGF0dXMiOiJwcm9kdWN0aW9uIiwic3VwcG9ydGVkTmV0d29ya3MiOlsidmlzYSIsIm1hc3RlcmNhcmQiLCJhbWV4IiwiZGlzY292ZXIiLCJtYWVzdHJvIiwiZWxvIl19LCJwYXlwYWxFbmFibGVkIjp0cnVlLCJicmFpbnRyZWVfYXBpIjp7InVybCI6Imh0dHBzOi8vcGF5bWVudHMuYnJhaW50cmVlLWFwaS5jb20iLCJhY2Nlc3NfdG9rZW4iOiJleUowZVhBaU9pSktWMVFpTENKaGJHY2lPaUpGVXpJMU5pSXNJbXRwWkNJNklqSXdNVGd3TkRJMk1UWXRjSEp2WkhWamRHbHZiaUlzSW1semN5STZJbWgwZEhCek9pOHZZWEJwTG1KeVlXbHVkSEpsWldkaGRHVjNZWGt1WTI5dEluMC5leUpsZUhBaU9qRTNORFkyTXpjME9ESXNJbXAwYVNJNklqZGpZVEUyTVRZMUxXRTJZakV0TkdJeU1TMWhNR0ppTFRnMlpHSTVaV1V5TkRBM09TSXNJbk4xWWlJNkltUm1lVFExYW1ScU0yUjRhMjE2TlcwaUxDSnBjM01pT2lKb2RIUndjem92TDJGd2FTNWljbUZwYm5SeVpXVm5ZWFJsZDJGNUxtTnZiU0lzSW0xbGNtTm9ZVzUwSWpwN0luQjFZbXhwWTE5cFpDSTZJbVJtZVRRMWFtUnFNMlI0YTIxNk5XMGlMQ0oyWlhKcFpubGZZMkZ5WkY5aWVWOWtaV1poZFd4MElqcG1ZV3h6Wlgwc0luSnBaMmgwY3lJNld5SjBiMnRsYm1sNlpTSXNJbTFoYm1GblpWOTJZWFZzZENKZExDSnpZMjl3WlNJNld5SkNjbUZwYm5SeVpXVTZWbUYxYkhRaUxDSkNjbUZwYm5SeVpXVTZRVmhQSWwwc0ltOXdkR2x2Ym5NaU9udDlmUS5ydFhicDlXSVB2SUNiSkNqYTNDLVY1WkgyQTNmSmF0SEUzVW1HU1JzUkN0VHlPaU5TZVJiWHF0ZHlESWFlcUZmTW1HUUhPNGxEQmFfS0djbHhCSnlXdyJ9LCJwYXlwYWwiOnsiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjp0cnVlLCJlbnZpcm9ubWVudE5vTmV0d29yayI6ZmFsc2UsInVudmV0dGVkTWVyY2hhbnQiOmZhbHNlLCJhbGxvd0h0dHAiOmZhbHNlLCJkaXNwbGF5TmFtZSI6IkJyYWludHJlZSBUZXN0aW5nIiwiY2xpZW50SWQiOiJBYUdsRjh1X1Joc1o4YzdSRnYzSWFnRUhQNHFqUTlvUnBadm9qMk5NZENXUGRKSWZ0VlRzUzRtU0FvdkowU0dxeHhlUjB3aXdRMndhTXgxeSIsImJhc2VVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbSIsImFzc2V0c1VybCI6Imh0dHBzOi8vY2hlY2tvdXQucGF5cGFsLmNvbSIsImRpcmVjdEJhc2VVcmwiOm51bGwsImVudmlyb25tZW50IjoibGl2ZSIsImJyYWludHJlZUNsaWVudElkIjoiQVJLcllSRGgzQUdYRHpXN3NPXzNiU2txLVUxQzdIR191V05DLXo1N0xqWVNETlVPU2FPdElhOXE2VnBXIiwibWVyY2hhbnRBY2NvdW50SWQiOiJCcmFpbnRyZWVUZXN0aW5nX2luc3RhbnQiLCJjdXJyZW5jeUlzb0NvZGUiOiJVU0QifX0="

class PaymentButtonBaseViewController: BaseViewController {

//    let apiClient: BTAPIClient

    var heightConstraint: CGFloat?

    private var paymentButton = UIView()

    override init(authorization: String) {
        // swiftlint:disable:next force_unwrapping
//        apiClient = BTAPIClient(authorization: authorization)!
        super.init(authorization: authorization)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Payment Button"
        view.backgroundColor = .systemBackground

        paymentButton = createPaymentButton()
        view.addSubview(paymentButton)

        NSLayoutConstraint.activate([
            paymentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            paymentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            paymentButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            paymentButton.heightAnchor.constraint(equalToConstant: heightConstraint ?? 100)
        ])
    }

    /// A factory method that subclasses must implement to return a payment button view.
    func createPaymentButton() -> UIView {
        UIView()
    }

    func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.setTitleColor(.lightGray, for: .disabled)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
