//
//  SignupVC.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/09/01.
//

import UIKit
import RevenueCat

class SignupVC: BaseViewController, UIViewControllerTransitioningDelegate {
    @IBOutlet private weak var nameTextField: AnimatedField!
    @IBOutlet private weak var emailTextFiled: AnimatedField!
    @IBOutlet private weak var passwordTextField: AnimatedField!
    @IBOutlet private weak var confirmPasswordTextField: AnimatedField!
    @IBOutlet private weak var signUpButton: UIButton!
    
    private var isSubscribed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        showCustomAlert(title:
                            "Sign Up", message: "By Clicking Sign Up you are agreeing with our Privacy Policy and Terms and Use. Also You Will be signed up for Lawie.") { [self] in
            if !Utility.shared.isPasswordValid(passwordTextField.text!) {
                passwordInfoBtnAction()
                return
            }
            if passwordTextField.text != passwordTextField.text {
                Utility.shared.alert(message: ErrorMessage.passwordMissMatch, isLong: false)
                return
            }
            
            Utility.shared.startLoadingActivity()
            ApiManager.shared.performSignUp(name: nameTextField.text!, password: passwordTextField.text!, confirmPassword: confirmPasswordTextField.text!, email: emailTextFiled.text!) { response in
                Utility.shared.hideLoadingActivity()
                guard response != nil else {
                    Utility.shared.alert(message: "Could not Sign Up. Please Try Again")
                    return
                }
                Utility.shared.alert(message: "Signup is successful. Please login", isLong: false){
                    self.navigationController?.pushViewController(self.router.loginViewController(), animated: true)
                }
            }
        }
    }
    
    @IBAction func goToLoginViewButtonAction(_ sender: UIButton) {
        navigationController?.pushViewController(router.loginViewController(), animated: true)
    }
    
    @objc private func passwordInfoBtnAction() {
        let infoBottomVC = InfoBottomSheetVC()
        infoBottomVC.modalPresentationStyle = .overCurrentContext
        infoBottomVC.transitioningDelegate = self
        
        self.present(infoBottomVC, animated: true)
        
        infoBottomVC.setupInfo(title: "Password should met the following criteria-", description: "  • Requires 1 uppercase letter\n  • Requires 1 lowercase letter\n  • Requires 1 digit\n  • Requires 1 special character\n  • Avoid any new line or dot(.) characters")
    }
    
    
    @IBAction func privacyPolicyButtonPressed(_ sender: UIButton) {
        let vc = self.router.customWebViewController()
        vc.webViewLink = "https://terms.lawie.app/privacy-policy"
        present(vc, animated: true)
    }
    
    @IBAction func termsOfUseButtonPressed(_ sender: UIButton) {
        let vc = self.router.customWebViewController()
        vc.webViewLink = "https://terms.lawie.app/terms-and-conditions"
        present(vc, animated: true)
    }
    
    @IBAction func aboutLawie(_ sender: UIButton) {
        let vc = self.router.customWebViewController()
        vc.webViewLink = "https://lawie.app/"
        present(vc, animated: true)
    }
    
    @IBAction func onFreeTrialPressed(_ sender: Any) {
        let controller = router.chatController()
        controller.isChatTrial = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension SignupVC: AnimatedFieldDelegate {
    func animatedFieldDidBeginEditing(_ animatedField: AnimatedField) {}
    
    func animatedField(_ animatedField: AnimatedField, didResizeHeight height: CGFloat) {}
    
    func animatedField(_ animatedField: AnimatedField, didSecureText secure: Bool) {}
    
    func animatedField(_ animatedField: AnimatedField, didChangePickerValue value: String) {}
    
    func animatedFieldDidChange(_ animatedField: AnimatedField) {}
    
    func animatedFieldDidEndEditing(_ animatedField: AnimatedField) {
        let validEmailUser = self.emailTextFiled.isValid
        signUpButton.isEnabled = validEmailUser
        signUpButton.alpha = validEmailUser ? 1.0 : 0.3
    }
    
}

extension SignupVC: AnimatedFieldDataSource {
    func animatedFieldLimit(_ animatedField: AnimatedField) -> Int? {
        switch animatedField.tag {
        case 8: return 30
        default: return nil
        }
    }
    
    func animatedFieldValidationError(_ animatedField: AnimatedField) -> String? {
        if animatedField == emailTextFiled {
            return "Email invalid! Please check again ;)"
        }
        return nil
    }
}

extension SignupVC {
    private func setupViews() {
        //Nmae
        setupAnimateTexField(textField: nameTextField, placeHolder: "Your Full Name", textFieldType: .none, dataSource: self, delegate: self, textFieldTag: 0)
        
        // User email Setup
        setupAnimateTexField(textField: emailTextFiled, placeHolder: "Write your email", textFieldType: .email, dataSource: self, delegate: self, textFieldTag: 1)
        
        //User Password Setup
        setupAnimateTexField(textField: passwordTextField, placeHolder: "Password", textFieldType: .password(6, 10), dataSource: self, delegate: self, textFieldTag: 2)
        
        //confirm Passowrd
        setupAnimateTexField(textField: confirmPasswordTextField, placeHolder: "Confirm Password", textFieldType: .password(6, 10), dataSource: self, delegate: self, textFieldTag: 3)
    }
}
