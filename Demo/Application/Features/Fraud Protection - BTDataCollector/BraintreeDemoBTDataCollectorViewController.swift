import UIKit
import CoreLocation
import BraintreeDataCollector
import BraintreeCore

class BraintreeDemoBTDataCollectorViewController: BraintreeDemoPaymentButtonBaseViewController {

    let locationManager = CLLocationManager()
    var dataLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Braintree Data Collector"
        createLocationPermissionButton()
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

    @objc func tappedRequestLocationAuthorization() {
        let locationStatus = locationManager.authorizationStatus

        switch locationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        default:
            progressBlock("Location authorization requested previously. Update authorization in Settings app.")
        }
    }

    private func createLocationPermissionButton() {
        let obtainLocationPermissionButton = UIButton(type: .system)
        obtainLocationPermissionButton.setTitle("Obtain Location Permission", for: .normal)
        obtainLocationPermissionButton.setTitleColor(.blue, for: .normal)
        obtainLocationPermissionButton.addTarget(self, action: #selector(tappedRequestLocationAuthorization), for: .touchUpInside)
        obtainLocationPermissionButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(obtainLocationPermissionButton)

        NSLayoutConstraint.activate([
            obtainLocationPermissionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            obtainLocationPermissionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
