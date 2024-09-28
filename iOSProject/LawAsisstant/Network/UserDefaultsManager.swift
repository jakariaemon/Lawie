
//  UserDefaultsManager.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/09/03.
//

import Foundation

class UserDefaultsUtility {
    
    static let shared = UserDefaultsUtility()
    
    var userToken: String {
         get {
             return UserDefaults.standard.string(forKey: DefaultKeys.TOKEN) ?? ""
         }
         set(newValue) {
             setValueInUserDefaults(value: newValue, key: DefaultKeys.TOKEN)
         }
     }
    
    var userID:Int {
        
        get {
            return UserDefaults.standard.value(forKey: DefaultKeys.USER_ID) as? Int ?? 0
        }
        set(newValue) {
            setValueInUserDefaults(value: newValue, key: DefaultKeys.USER_ID)
        }
        
    }
    
    var email: String {
        
        get {
            return UserDefaults.standard.string(forKey: DefaultKeys.USER_EMAIL) ?? ""
        }
        set(newValue) {
            print("Setting user email")
            setValueInUserDefaults(value: newValue, key: DefaultKeys.USER_EMAIL)
            print("newUserDefault value for email", email)
        }
        
    }
    
    var name:String {
        
        get {
            return UserDefaults.standard.string(forKey: DefaultKeys.USER_FIRST_NAME) ?? ""
        }
        set(newValue) {
            setValueInUserDefaults(value: newValue, key: DefaultKeys.USER_FIRST_NAME)
        }
        
    }
    
    var refreshToken:String {
        
        get {
            return UserDefaults.standard.string(forKey: DefaultKeys.REFRESH_TOKEN) ?? ""
        }
        set(newValue) {
            setValueInUserDefaults(value: newValue, key: DefaultKeys.REFRESH_TOKEN)
        }
        
    }
    
    var subscriptionPrice: String {
        get {
            return UserDefaults.standard.string(forKey: DefaultKeys.SUBSCRIPTION_PRICE) ?? ""
        }
        set(newValue) {
            setValueInUserDefaults(value: newValue, key: DefaultKeys.SUBSCRIPTION_PRICE)
        }
    }
    
    var visitedLoginPage: Bool {
        get {
            return UserDefaults.standard.bool(forKey: DefaultKeys.VISITED_LOGIN)
        }
        set(newValue) {
            setValueInUserDefaults(value: newValue, key: DefaultKeys.VISITED_LOGIN)
        }
        
    }
    
    var isSubscribed: Bool {
        get {
            return UserDefaults.standard.bool(forKey: DefaultKeys.SUBSCRIBED)
        }
        set(newValue) {
            setValueInUserDefaults(value: newValue, key: DefaultKeys.SUBSCRIBED)
        }
        
    }
    
    var isLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: DefaultKeys.isLoggedIn)
        }
        set(newValue) {
            setValueInUserDefaults(value: newValue, key: DefaultKeys.isLoggedIn)
        }
        
    }
    
    var isTrialOn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isTrialOn")
        }
        set(newValue) {
            setValueInUserDefaults(value: newValue, key: "isTrialOn")
        }
        
    }
       
    func getUserWelcome() -> String {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return "Welcome \(name == "" ? "User" : name)"
    }
    
    var freeTrialCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: DefaultKeys.FREE_TRIAL_COUNT)
        }
        set(newValue) {
            setValueInUserDefaults(value: newValue, key: DefaultKeys.FREE_TRIAL_COUNT)
        }
    }
    
    func crearAllData() {
        UserDefaults.standard.removeObject(forKey: DefaultKeys.isLoggedIn)
        UserDefaults.standard.removeObject(forKey: DefaultKeys.TOKEN)
        UserDefaults.standard.removeObject(forKey: DefaultKeys.USER_ID)
        UserDefaults.standard.removeObject(forKey: DefaultKeys.USER_FIRST_NAME)
        UserDefaults.standard.removeObject(forKey: DefaultKeys.USER_LAST_NAME)
        UserDefaults.standard.removeObject(forKey: DefaultKeys.NAME)
        UserDefaults.standard.removeObject(forKey: DefaultKeys.USER_EMAIL)
        UserDefaults.standard.removeObject(forKey: DefaultKeys.PROFILE_PICTURE)
        UserDefaults.standard.removeObject(forKey: DefaultKeys.REFRESH_TOKEN)
        UserDefaults.standard.removeObject(forKey: DefaultKeys.PHONE_NUMBER)
        UserDefaults.standard.removeObject(forKey: DefaultKeys.AUTHORITIES)
        UserDefaults.standard.removeObject(forKey: DefaultKeys.PASSWORD_UPDATED)
        UserDefaults.standard.removeObject(forKey: DefaultKeys.PROFILE_COMPLETED)
    }
    
    private func setValueInUserDefaults<T>(value: T,  key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
}

extension UserDefaults {
    func value<T>(forKey key: String) -> T? {
        return object(forKey: key) as? T
    }
}
