//
//  UIApplication+URLOpener.swift
//  BraintreeCore
//
//  Created by Samantha Cannillo on 12/6/23.
//

import UIKit

public protocol URLOpener {
    
    func canOpenURL(_ url: URL) -> Bool
    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey : Any],
        completionHandler completion: ((Bool) -> Void)?
    )
}

extension UIApplication: URLOpener { }
