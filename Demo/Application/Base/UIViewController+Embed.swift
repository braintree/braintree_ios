import SwiftUI
import UIKit

extension UIViewController {

    /// Embeds a SwiftUI view as a child view controller, pinned to the safe area.
    func embed(_ swiftUIView: some View) {
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        hostingController.beginAppearanceTransition(true, animated: false)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
        hostingController.endAppearanceTransition()
    }
}
