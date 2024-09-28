//
//  LoginView.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/08/31.
//

import UIKit
import RevenueCat

class LoginView: BaseViewController, UIViewControllerTransitioningDelegate {
    @IBOutlet private weak var emailTextField: AnimatedField!
    @IBOutlet private weak var passwordTextField: AnimatedField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var backButtonView: RoundedView!
    
    private var isSubscribed = false
    var isLoginFromSignUp = true
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        guard let phoneNumber =  self.emailTextField.text, !phoneNumber.isEmpty else {
            Utility.shared.alert(message: "Please enter a valid email")
            return
        }
        
        guard let password = self.passwordTextField.text, !password.isEmpty else {
            Utility.shared.alert(message: "Please enter your password")
            return
        }
        
        sharedUtility.startLoadingActivity()
        ApiManager.shared.performLogin(userName: emailTextField.text!, password: passwordTextField.text!) { success, response in
            self.sharedUtility.hideLoadingActivity()
            
            if success {
                Purchases.shared.invalidateCustomerInfoCache()
                Purchases.shared.logIn(UserDefaultsUtility.shared.email) { (customerInfo, created, error) in
                    if let error = error {
                        self.showCustomAlert(title: "Error", message: error.localizedDescription)
                    } else {
                        if let isSubscribed = customerInfo?.activeSubscriptions.isEmpty {
                            self.isSubscribed = isSubscribed ? false : true
                            self.sharedUserDefaults.isLoggedIn = true
                            
                            self.navigationController?.pushViewController( self.isSubscribed ? self.router.homeNavigationController() :
                                                                            self.router.initialSubscriptionViewController(), animated: true)
                        }
                        
                    }
                }
            }else {
                self.sharedUtility.alert(message: "Could not sign in this time please check your email and passsword")
            }
        }
    }
    
    @IBAction func forgotPasswordButtonAction(_ sender: UIButton) {
        
        self.showCustomAlert(title: "Forgot Password?", message: "Do you want a password reset link to your email?") {
            self.sharedUtility.startLoadingActivity()
            ApiManager.shared.forgotPassword(withUserName: self.sharedUserDefaults.email) { success, message in
                if success {
                    self.sharedUtility.alert(message: message!)
                }else {
                    self.sharedUtility.alert(message: "Email could not be sent this time. Please try again")
                }
            }
        }
    }
    
    
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        navigationController?.pushViewController(router.signUpViewController(), animated: true)
    }
    
    func setupViews() {
        //loginViewTitleLabel.font = .robotMedium(size: 28)
        backButtonView.isHidden = isLoginFromSignUp
        
        // User email Setup
        setupAnimateTexField(textField: emailTextField, placeHolder: "Write your email", textFieldType: .email, dataSource: self, delegate: self, textFieldTag: 0)
        
        //User Password Setup
        setupAnimateTexField(textField: passwordTextField, placeHolder: "Password", textFieldType: .password(6, 10), dataSource: self, delegate: self, textFieldTag: 1)
    }
    
}

extension LoginView: AnimatedFieldDelegate {
    func animatedFieldDidBeginEditing(_ animatedField: AnimatedField) {}
    
    func animatedFieldDidEndEditing(_ animatedField: AnimatedField) {}
    
    func animatedField(_ animatedField: AnimatedField, didResizeHeight height: CGFloat) {}
    
    func animatedField(_ animatedField: AnimatedField, didSecureText secure: Bool) {}
    
    func animatedField(_ animatedField: AnimatedField, didChangePickerValue value: String) {}
    
    func animatedFieldDidChange(_ animatedField: AnimatedField) {}
}


extension LoginView: AnimatedFieldDataSource {
    func animatedFieldLimit(_ animatedField: AnimatedField) -> Int? {
        switch animatedField.tag {
        case 8: return 30
        default: return nil
        }
    }
    
    func animatedFieldValidationError(_ animatedField: AnimatedField) -> String? {
        if animatedField == emailTextField {
            return "Email invalid! Please check again ;)"
        }
        return nil
    }
}
