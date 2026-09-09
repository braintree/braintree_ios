import UIKit

class PaymentActionsViewController: BaseViewController {

    private let authorization: String

    override init(authorization: String) {
        self.authorization = authorization
        super.init(authorization: authorization)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.removeGestureRecognizer(tapToDismissKeyboard)
        title = "Payment Actions"
        embed(PaymentActionsView(authorization: authorization))
    }
}
