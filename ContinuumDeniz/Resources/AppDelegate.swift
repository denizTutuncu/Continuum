//
//  AppDelegate.swift
//  ContinuumDeniz
//
//  Created by Deniz Tutuncu on 2/26/19.
//  Copyright © 2019 Deniz Tutuncu. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        checkAccountStatus { (success) in
            if success {
                let fetchedUserStatment = success ? "Successfully retrieved a logged in user" : "Failed to retrieve a logged in user"
                print(fetchedUserStatment)
            }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (success, error) in
                if let error = error {
                    print("There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)")
                    return
                }
                success ? print("Successfully authorized to send push notfiication") : print("Denied, Cannot send this person notificiation")
            })
        }
    application.registerForRemoteNotifications()
    return true
    }

    func checkAccountStatus(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { (accountStatus, error) in
            if let error = error {
                print("Error checking user status: \(error): \(error.localizedDescription)")
                completion(false); return
            } else {
                DispatchQueue.main.async {
                    let tabbarController = self.window?.rootViewController
                    let errorText = "Sign into iCloud in Settings"
                    
                    switch accountStatus {
                    case .available:
                        completion(true)
                    case .couldNotDetermine:
                        tabbarController?.presentSimpleAlertWith(title: errorText, message: "No account found")
                        completion(false)
                    case .noAccount:
                        tabbarController?.presentSimpleAlertWith(title: errorText, message: "There was an unknown error fetching your iCloud Account")
                        completion(false)
                    case .restricted:
                        tabbarController?.presentSimpleAlertWith(title: errorText, message: "Your iCloud account is restricted")
                        completion(false)
                    }
                }
            }
            
        }
    }
}

