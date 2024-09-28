//
//  InitVC.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/08/27.
//

import UIKit
import RevenueCat

class InitVC: BaseViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var priceDescriptionLabel: UILabel!
    @IBOutlet private weak var moneyInfoLabel: UILabel!
    @IBOutlet private weak var premiumDescTextview: UITextView!
    
    private var price: String = "$9.99 "
    private var package: Package!
    private var isSubscribedAnyProduct = false
    private var isSubscribed = false
    private var customerInfo: CustomerInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        // fetch the offerings from the revenue cat
        Purchases.shared.getOfferings { Offering, error in
            if let offers = Offering {
                if let package = offers.current?.availablePackages.first {
                    self.package = package
                }
                
                if let price = offers.current?.availablePackages.first?.localizedPriceString {
                    self.moneyInfoLabel.text = price + "/Month"
                    self.price = price
                    self.sharedUserDefaults.subscriptionPrice = price
                }
                
            }else {
                debugPrint(error?.localizedDescription ?? "")
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        premiumDescTextview.text = " Get the Pro version of Lawie!"
        + "\n\n" +   "Chat and Get suggestions from Lawie anywhere, anytime."
        + "\n\n" + "Unlimited legal advice via chat. "
        
        + "\n\n" +  "Auto-Renewal: Subscription renews automatically unless canceled at least 24 hours before the end of the current period. Manage your subscription in the App Store settings."
        
        + "\n\n" +  "Trial: For new user after 3 day trials subscription will automatically renew at \(self.price)/month unless cancelled before 24 hours of trial ending"
        
        self.priceDescriptionLabel.text = " \(self.price)/Month With 3 day trial for new user"
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollView.layoutSubviews()
        self.scrollView.contentSize = self.contentView.bounds.size
    }
    
    @IBAction func trialButtonAction(_ sender: UIButton) {
        showCustomAlert(title: "Subscribe", message:
                            " By subscribing, you agree to our Terms of Use(https://terms.lawie.app/terms-and-conditions) and Privacy Policy(https://terms.lawie.app/privacy-policy).") {
            
            self.sharedUtility.startLoadingActivity()
            Purchases.shared.purchase(package: self.package) { transaction, purchaserInfo, error, userCancelled in
                if let error = error {
                    // Handle error
                    print("Purchase failed: \(error.localizedDescription)")
                    self.sharedUtility.alert(message: "Purchase failed: \(error.localizedDescription)")
                } else if userCancelled {
                    // Handle user cancellation
                    print("User cancelled the purchase")
                    self.sharedUtility.alert(message: "User cancelled the purchase")
                } else {
                    // Purchase successful
                    print("Purchase successful!")
                    self.sharedUtility.alert(message: "Purchase is successfull !")
                    self.sharedUserDefaults.isSubscribed = true
                    self.navigationController?.pushViewController(self.router.homeNavigationController(), animated: true)
                }
            }
        }
    }
    
    
    
    @IBAction func restoreButtonPressed(_ sender: UIButton) {
        
        Purchases.shared.restorePurchases { (customerInfo, error) in
            if let error = error {
                // Handle error
                print("Error restoring purchases: \(error.localizedDescription)")
            } else if let customerInfo = customerInfo {
                // Check if the user has active entitlements
                if customerInfo.entitlements.all[
                    "LawieProMonthly9.99"]?.isActive == true {
                    // The user has an active subscription
                    print("Subscription restored successfully!")
                    self.sharedUtility.alert(message: "Subscription restored successfully!")
                    
                    self.sharedUserDefaults.isSubscribed = true
                    self.navigationController?.pushViewController(self.router.homeNavigationController(), animated: true)
                } else {
                    // No active subscription found
                    print("No active subscription found.")
                    self.sharedUserDefaults.isSubscribed = false
                    self.sharedUtility.alert(message: "No active subscription found.")
                }
            }
        }
    }
    
    
    @IBAction func privacyPolicyButtonPressed(_ sender: UIButton) {
        let vc = self.router.customWebViewController()
        vc.webViewLink = "https://terms.lawie.app/privacy-policy"
        present(vc, animated: true)
    }
    
    @IBAction func tocButtonPressed(_ sender: UIButton) {
        let vc = self.router.customWebViewController()
        vc.webViewLink = "https://terms.lawie.app/terms-and-conditions"
        present(vc, animated: true)
    }
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        let vc = self.router.profileViewController()
        vc.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
