//import UIKit
//import BraintreeDataCollector
//import BraintreeCore
//
//class DataCollectorViewController: PaymentButtonBaseViewController {
//
//    var dataLabel = UILabel()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Braintree Data Collector"
//    }
//
//    override func createPaymentButton() -> UIView {
//        let dataCollectorButton = createButton(title: "Collect Device Data", action: #selector(tappedCollect))
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.adjustsFontSizeToFitWidth = true
//        label.translatesAutoresizingMaskIntoConstraints = false
//
//        self.dataLabel = label
//
//        let stackView = UIStackView(arrangedSubviews: [dataCollectorButton, label])
//        stackView.axis = .vertical
//        stackView.spacing = 5
//        stackView.alignment = .center
//        stackView.distribution = .fillEqually
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//
//        return stackView
//    }
//
//    @objc func tappedCollect() {
//        let dataCollector = BTDataCollector(apiClient: apiClient)
//
//        progressBlock("Started collecting all data...")
//        dataCollector.collectDeviceData { deviceData, error in
//            guard let deviceData else {
//                self.progressBlock(error?.localizedDescription)
//                return
//            }
//
//            self.dataLabel.text = deviceData
//            self.progressBlock("Collected all device data!")
//        }
//    }
//}
