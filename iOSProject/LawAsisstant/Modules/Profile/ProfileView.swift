//
//  ProfileView.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/09/11.
//

import UIKit
import RevenueCat

class ProfileView: BaseViewController {
    @IBOutlet private weak var currentPlanLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var textViewForPlan: UITextView!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var suscriptionNameLabel: UILabel!
    @IBOutlet private weak var changePlanButton: UIButton!
    @IBOutlet private weak var heightOfNavBarView: NSLayoutConstraint!
    
    private var isSubscribed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.layoutSubviews()
        self.scrollView.contentSize = self.containerView.bounds.size
        nameLabel.text = sharedUserDefaults.name
        emailLabel.text = sharedUserDefaults.email
        priceLabel.text = sharedUserDefaults.subscriptionPrice + "/Month"
        self.textViewForPlan.text = " Get the Pro version of Lawie!"
        + "\n\n" +   "Chat and Get suggestions from Lawie anywhere, anytime."
        + "\n\n" + "Unlimited legal advice via chat. "
        
        + "\n\n" +  "Auto-Renewal: Subscription renews automatically unless canceled at least 24 hours before the end of the current period. Manage your subscription in the App Store settings."
        
        + "\n\n" +  "Trial: For new user after 3 day trials subscription will automatically renew at \(self.sharedUserDefaults.subscriptionPrice)/month unless cancelled before 24 hours of trial ending"
        
        //MARK: - NavBarViewUI
        if sharedUserDefaults.isSubscribed {} else {
            currentPlanLabel.text = "Available plan"
            changePlanButton.setTitle( "Subscribe", for: .normal)
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        let vc = router.settingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func changePlanButtonChanged(_ sender: UIButton) {
        if sharedUserDefaults.isSubscribed {
            showCustomAlert(title: "Cancel Subscription? ", message: "Do you wish to cancel Subscription ?") {
                Purchases.shared.getCustomerInfo { (customerInfo, error) in
                    if let error = error {
                        // Handle error
                        print("Error fetching customer info: \(error.localizedDescription)")
                    } else if let customerInfo = customerInfo {
                        if let managementURL = customerInfo.managementURL {
                            
                            UIApplication.shared.open(managementURL, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
        }else {
            self.navigationController?.pushViewController(self.router.initialSubscriptionViewController(), animated: true)
        }
    }
}
