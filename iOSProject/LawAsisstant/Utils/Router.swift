//
//  Router.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 6/9/24.
//

import Foundation
import UIKit

class Router {
    
    let mainStoryBoard = UIStoryboard.init(name: AppStrings.StoryboardNames.main, bundle: nil)
    let homeStoryBoard = UIStoryboard.init(name: AppStrings.StoryboardNames.home, bundle: nil)
    let optionStoryBoard = UIStoryboard.init(name: AppStrings.StoryboardNames.optionView, bundle: nil)
    
    func splashController() -> SplashController {
        return mainStoryBoard.instantiateViewController(identifier: AppStrings.ViewControllerNames.splashView) as! SplashController
    }
    
    func homeNavigationController() -> HomeNavigationController {
        return homeStoryBoard.instantiateViewController(identifier: AppStrings.ViewControllerNames.homeNavVC) as! HomeNavigationController
    }
    
    func optionController() -> OptionController {
        return optionStoryBoard.instantiateViewController(identifier: AppStrings.ViewControllerNames.optionVC) as! OptionController
    }
    
    func signUpViewController() -> SignupVC {
        return .instantiate()
    }
    
    func predefinedPromptController() -> PredefinedPromptController {
        return optionStoryBoard.instantiateViewController(identifier: AppStrings.ViewControllerNames.predefinedPromtVC) as! PredefinedPromptController
    }
    
    func chatController() -> ChatController {
        return optionStoryBoard.instantiateViewController(identifier: AppStrings.ViewControllerNames.chatVC) as! ChatController
    }
    
    func loginViewController() -> LoginView {
        return .instantiate()
    }
    
    func profileViewController() -> ProfileView {
        return .instantiate()
    }
    
    func settingViewController() -> SettingsView {
        return .instantiate()
    }
    
    func initialSubscriptionViewController() -> InitVC {
        return .instantiate()
    }
    
    func customWebViewController() -> CustomWebView {
        return .instantiate()
    }
    
}


struct AppStrings {
    struct StoryboardNames {
        static let home = "Home"
        static let main = "Main"
        static let optionView = "OptionView"
    }
    
    struct ViewControllerNames {
        static let splashView = "SplashController"
        static let homeNavVC = "HomeNavigationController"
        static let optionVC = "OptionController"
        static let predefinedPromtVC = "PredefinedPromptController"
        static let chatVC = "ChatController"
    }
}
