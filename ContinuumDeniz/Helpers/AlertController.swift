//
//  AlertController.swift
//  ContinuumDeniz
//
//  Created by Deniz Tutuncu on 2/26/19.
//  Copyright © 2019 Deniz Tutuncu. All rights reserved.
//

import UIKit


extension UIViewController {
    
    
    func presentSimpleAlertWith(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        present(alertController, animated: true)
    }
}

class AlertController {
    
    static let shared = AlertController()
    
    func presentCommentAlertController() -> UIAlertController {
        
        let alertController = UIAlertController(title: "Continuum", message: "Add a comment", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Your comment here"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(cancelAction)

        return alertController
    }
    
    func presentErrorMessageAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: "Continuum", message: "Please select a photo or put a caption before trying to create a post", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        return alertController
    }
}
