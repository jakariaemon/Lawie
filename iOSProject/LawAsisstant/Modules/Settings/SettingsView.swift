//
//  SettingsView.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/09/11.
//

import UIKit
import RevenueCat

class SettingsView: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changedPasswordBtnPressed(_ sender: UIButton) {
        showCustomAlert(title: "Want to change your password?", message: "An email will be sent for password change to you mail") {
            self.sharedUtility.startLoadingActivity()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.sharedUtility.alert(message: "The email has been sent for your passowrd change procedure")
            }
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        showCustomAlert(title: "Log Out", message: "Do you wish to Log Out?") {
            self.clearRevenueCatCacheAndRefresh()
        }
    }
    
    @IBAction func deleteAccountBtnPressed(_ sender: UIButton) {
        showCustomAlert(title: "Delete Account !", message: "Do you wish to Delete your Acount?") {
            self.sharedUtility.startLoadingActivity()
            ApiManager.shared.deleteAccount(withUserName: "") { succes, message in
                self.sharedUtility.hideLoadingActivity()
                if succes {
                    if self.sharedUserDefaults.isSubscribed {
                        Purchases.shared.logOut(completion: nil)
                    }
                    
                    self.sharedUserDefaults.isLoggedIn = false
                    self.sharedUserDefaults.isSubscribed = false
                    Purchases.shared.invalidateCustomerInfoCache()
                    if let message = message {
                        self.sharedUtility.alert(message: message, isLong: false) {
                            self.navigationController?.setViewControllers([self.router.loginViewController()], animated: true)
                        }
                    }
                }else {
                    if let message = message {
                        self.sharedUtility.alert(message: message
                        )
                    }
                }
            }
        }
    }
    
    func clearRevenueCatCacheAndRefresh() {
        if self.sharedUserDefaults.isSubscribed {
            sharedUtility.startLoadingActivity()
            Purchases.shared.logOut(completion: nil)
        }
        self.sharedUserDefaults.isLoggedIn = false
        self.sharedUserDefaults.isSubscribed = false
        Purchases.shared.invalidateCustomerInfoCache()
        self.sharedUtility.alert(message: "Logged Out Sccessfully!")
        self.navigationController?.setViewControllers([self.router.loginViewController()], animated: true)
    }
    
    @IBAction func contactUsButtonPressed(_ sender: UIButton) {
        self.showCustomAlert(title: "Contact Us", message:
                                "If you have any queries \nPlease contact us at admin@lawie.app ")
    }
    
    @IBAction func tocButtonPressed(_ sender: UIButton) {
        let vc = self.router.customWebViewController()
        vc.webViewLink = "https://terms.lawie.app/terms-and-conditions"
        present(vc, animated: true)
    }
    
    @IBAction func privacyPolicyButtonPressed(_ sender: UIButton) {
        let vc = self.router.customWebViewController()
        vc.webViewLink = "https://terms.lawie.app/privacy-policy"
        present(vc, animated: true)
    }
    
    @IBAction func aboutLawieButtonPressed(_ sender: UIButton) {
        let vc = self.router.customWebViewController()
        vc.webViewLink = "https://lawie.app/"
        present(vc, animated: true)
    }
    
}

