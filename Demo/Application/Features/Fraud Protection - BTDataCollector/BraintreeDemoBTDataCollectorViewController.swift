import UIKit
import BraintreeDataCollector
import BraintreeCore

class BraintreeDemoBTDataCollectorViewController: BraintreeDemoPaymentButtonBaseViewController {

    var dataLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Braintree Data Collector"
    }

    override func createPaymentButton() -> UIView! {
        let dataCollectorButton = UIButton(type: .system)
        dataCollectorButton.setTitle("Collect Device Data", for: .normal)
        dataCollectorButton.setTitleColor(.blue, for: .normal)
        dataCollectorButton.setTitleColor(.lightGray, for: .highlighted)
        dataCollectorButton.setTitleColor(.lightGray, for: .disabled)
        dataCollectorButton.addTarget(self, action: #selector(tappedCollect), for: .touchUpInside)
        dataCollectorButton.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false

        self.dataLabel = label

        let stackView = UIStackView(arrangedSubviews: [dataCollectorButton, label])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dataCollectorButton.heightAnchor.constraint(equalToConstant: 19.5),
            label.heightAnchor.constraint(equalToConstant: 19.5)
        ])

        return stackView
    }

    @objc func tappedCollect() {
        let dataCollector = BTDataCollector(apiClient: apiClient)

        progressBlock("Started collecting all data...")
        dataCollector.collectDeviceData { deviceData, error in
            guard let deviceData else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            self.dataLabel.text = deviceData
            self.progressBlock("Collected all device data!")
        }
    }
}
