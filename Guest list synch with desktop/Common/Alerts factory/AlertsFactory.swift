//
//  AlertsFactory.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 03.11.2022.
//

import Foundation
import UIKit

class AlertsFactory {
    static let shared = AlertsFactory()
    private init() {}
    
    func showAlert(title: String?,
                   message: String?,
                   viewController: UIViewController,
                   okAlertTitle: String,
                   secondAlertTitle: String?,
                   okCompletion: (() -> ())?,
                   canselCompletion: (() ->())?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title:  okAlertTitle, style: .default) {_ in
            if let okCompletion {
                okCompletion()
            }
        }
        alertController.addAction(okAction)
        if let secondAlertTitle {
            let canselAction = UIAlertAction(title: secondAlertTitle, style: .cancel) { _ in
                if let canselCompletion {
                    canselCompletion()
                }
            }
            alertController.addAction(canselAction)
        }
        viewController.present(alertController, animated: true)
    }
}
