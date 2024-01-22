//
//  UIViewController+Extensions.swift
//  Demo
//
//  Created by Alekhya Geddam on 1/19/24.
//  Copyright © 2024 braintree. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func label(_ text: String, _ font: UIFont = .boldSystemFont(ofSize: 15)) -> UILabel {
        let label = UILabel()
        label.font = font
        label.text = text
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }
    
    func textField(
        placeholder: String? = nil,
        text: String? = nil,
        clearButton: UITextField.ViewMode = .never
    ) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.text = text
        textField.clearButtonMode = clearButton
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }
    
    func button(
        title: String,
        titleColor: UIColor = .white,
        font: UIFont = .boldSystemFont(ofSize: 15),
        action: Selector
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
