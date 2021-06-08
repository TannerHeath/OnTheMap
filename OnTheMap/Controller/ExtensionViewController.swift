//
//  ExtensionViewController.swift
//  OnTheMap
//
//  Created by Tanner Heath on 5/25/21.
//

import Foundation
import UIKit

extension UIViewController {
    
    // MARK: Show alerts
    
    func showAlert(message: String, title: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true)
    }
    
    // MARK: Open links in Safari
    
    func openLink(_ url: String) {
        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else {
            showAlert(message: "Link cannot be opened", title: "Invalid Link")
            return
        }
        UIApplication.shared.open(url, options: [:])
    }
}
