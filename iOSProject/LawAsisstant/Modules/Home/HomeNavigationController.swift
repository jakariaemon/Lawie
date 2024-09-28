//
//  HomeNavigationController.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 10/9/24.
//

import UIKit


enum HomeTabs {
    case TAB_HOME
    case TAB_PROFILE
}


class HomeNavigationController: BaseViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var homeIcon: UIImageView!
    @IBOutlet weak var profileIcon: UIImageView!
    
    @IBOutlet weak var homeTitleText: UILabel!
    @IBOutlet weak var profileTitleText: UILabel!
    
    var selectedTab = HomeTabs.TAB_HOME
    
    private var optionController: OptionController?
    private var profileController: ProfileView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTab()
    }
    
    private func setupTab() {
        optionController?.removeFromParent()
        profileController?.removeFromParent()
        
        homeIcon.image = UIImage(named: selectedTab == HomeTabs.TAB_HOME ? "ic_home_selected" : "ic_home_unselected")
        profileIcon.image = UIImage(named: selectedTab == HomeTabs.TAB_PROFILE ? "ic_profile_selected" : "ic_profile_unselected")
        
        homeTitleText.textColor = UIColor(named: selectedTab == HomeTabs.TAB_HOME ? "ColorWhite" : "ColorBorder")
        profileTitleText.textColor = UIColor(named: selectedTab == HomeTabs.TAB_PROFILE ? "ColorWhite" : "ColorBorder")
        
        homeTitleText.font = UIFont.systemFont(ofSize: 14.0, weight: selectedTab == HomeTabs.TAB_HOME ? .semibold : .regular)
        profileTitleText.font = UIFont.systemFont(ofSize: 14.0, weight: selectedTab == HomeTabs.TAB_PROFILE ? .semibold : .regular)
        
        if selectedTab == HomeTabs.TAB_HOME {
            setupHomeView()
            
        } else {
            setupProfileView()
        }
    }
    
    private func setupHomeView() {
        optionController = router.optionController()
        
        if let controller = optionController {
            addChild(controller)
            
            containerView.addSubview(controller.view)
            controller.didMove(toParent: self)
            controller.view.frame = containerView.bounds
        }
    }
    
    private func setupProfileView() {
        profileController = router.profileViewController()
        
        if let controller = profileController {
            addChild(controller)
            
            containerView.addSubview(controller.view)
            controller.didMove(toParent: self)
            controller.view.frame = containerView.bounds
        }
    }

    @IBAction func onHomePressed(_ sender: Any) {
        if selectedTab == HomeTabs.TAB_HOME {
            return
        }
        
        selectedTab = HomeTabs.TAB_HOME
        setupTab()
    }
    
    @IBAction func onProfilePressed(_ sender: Any) {
        if selectedTab == HomeTabs.TAB_PROFILE {
            return
        }
        
        selectedTab = HomeTabs.TAB_PROFILE
        setupTab()
    }
    
}
