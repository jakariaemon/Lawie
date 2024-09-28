//
//  SplashController.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 6/9/24.
//

import UIKit
import Lottie

class SplashController: BaseViewController {
    @IBOutlet private weak var splashContainer: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splashContainer.play() { played in
            if played {
                if self.sharedUserDefaults.isLoggedIn && self.sharedUserDefaults.isSubscribed {
                    self.navigationController?.pushViewController(self.router.homeNavigationController(), animated: true)
                }else if self.sharedUserDefaults.isLoggedIn && !self.sharedUserDefaults.isSubscribed {
                    self.navigationController?.pushViewController(self.router.initialSubscriptionViewController(), animated: true)
                }else {
                    self.navigationController?.pushViewController(self.router.signUpViewController(), animated: true)
                }

            }
        }
    }

}
