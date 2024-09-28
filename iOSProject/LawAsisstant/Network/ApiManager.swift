//
//  ApiManager.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/09/02.
//

import Foundation
import Alamofire
import SystemConfiguration
import PKHUD

class ApiManager {
    static let shared = ApiManager()

    struct Api {
        static let BASE_URL = "https://demo.lawie.app/"
        
        static let SIGN_UP = BASE_URL + "signup"
        static let LOGIN: String = BASE_URL + "login/"
        static let FORGOT_PASSWORD = BASE_URL + "forgot-password"
        static let CHANGE_PASSWORD = BASE_URL + "user-service/change-password"
        static let DELETE = BASE_URL + "delete-account"
        static let GET_PROFILE = BASE_URL + "user-service/"
        
        // For Chat
        static let SEND_CHAT_MESSAGE = BASE_URL + "chat/"
        static let UPLOAD_DOCUMENT = BASE_URL + "ml/upload/"
        static let UPLOAD_STATUS = BASE_URL + "ml/progress/"
        static let ADAPTER_LIST = BASE_URL + "ml/adapter_list/?user_id="
        
    }
    
    struct Auth {
        static let userName = ""
        static let paswword = ""
    }
    
    enum HTTPMethod: String {
        case GET
        case PUT
        case POST
        case DELETE
    }
    
    enum APIError: Error {
        case faileedToGetData
    }
    
    private func getAuthString()-> String {
        let userPasswordString = "\(ApiManager.Auth.userName):\(ApiManager.Auth.paswword)"
        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8)
        let base64EncodedCredential = userPasswordData!.base64EncodedString(options: [])
        let authString = "Basic \(base64EncodedCredential)"
        
        return authString
    }
    
    //MARK: - Sazid's Code
    var headers:HTTPHeaders?
    var authToken:String?
    var sessionManager: Session?
    private var deviceId = Utility.shared.getDeviceId()
    private var deviceType = UIDevice.current.model
    
    private init(){
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 20
    }
    
    private var userDefaults = UserDefaultsUtility.shared
    
    var loggedInInfo: LoginResponse? {
        didSet {
            print("Savign Login Data from Sever to UserDefaults")
            if let token = loggedInInfo?.token {
                authToken = token
                headers = getHeader()
                userDefaults.userToken = token
            }
            
            if let userID = loggedInInfo?.user?.id{
                userDefaults.userID = userID
            }
            
            if let email = loggedInInfo?.user?.email {
                print("saving user email in userDefaults", email)
                userDefaults.email = email
            }
            
            if let firstName = loggedInInfo?.user?.name {
                userDefaults.name = firstName
            }
            
        }
    }
    
    // Generate Headers
    func getHeader() -> HTTPHeaders? {
        var authorization:String!
        if UserDefaults.standard.string(forKey: DefaultKeys.TOKEN) != nil {
            let token = UserDefaults.standard.string(forKey: DefaultKeys.TOKEN)
            authorization =  "bearer " + (token ?? "")
        } else {
            authorization = "bearer " + (loggedInInfo?.token ?? "")
        }
        
        return [
            // "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": authorization]
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let available = (isReachable && !needsConnection)
        
        return available
    }

}

struct DefaultKeys {
    static let isLoggedIn = "isLoggedIn"
    static let TOKEN = "authToken"
    static let USER_ID = "userID"
    static let USER_FIRST_NAME = "firstName"
    static let USER_LAST_NAME = "lastName"
    static let NAME = "name"
    static let USER_EMAIL = "email"
    static let PROFILE_PICTURE = "profilePicture"
    static let REFRESH_TOKEN = "refresh_token"
    static let PHONE_NUMBER = "phone_number"
    static let AUTHORITIES = "authorities"
    static let PASSWORD_UPDATED = "password_updated"
    static let PROFILE_COMPLETED = "profile_completed"
    static let DEFAULT_ACCOUNT = "default_account"
    static let SUBSCRIPTION_PRICE = "subscription_price"
    
    // DO NOT remove it from User default
    static let VISITED_LOGIN = "visited_login"
    static let SUBSCRIBED = "subscribed"
    static let FREE_TRIAL_COUNT = "FREE_TRIAL_COUNT"
    
}

struct APIkey {
    static let authToken = "Authorization"
}

struct ErrorMessage {
    static let networkError = "Please check your internet connection"
    static let emptyPhone = "Phone Number can not be empty"
    static let passwordValidation = "Please follow the instructions to set your password.\n  • Requires 1 uppercase letter\n  • Requires 1 lowercase letter\n  • Requires 1 digit\n  • Requires 1 special character\n  • Avoid any new line or dot(.) characters"
    static let passwordMissMatch = "Password is not Matched"
    static let termsAndConditionCheck = "Please go through the Terms and Condition"
    
    static let common_error_message = "Something went wrong. Please try again."
    static let common_success_message = "Request done successfully!"
}


//MARK: - Loing and SignUp
extension ApiManager {
    
    func performLogin(userName: String, password: String, completion: @escaping (Bool, LoginResponse?) -> ()) {
        let apiManager = ApiManager.shared
        
        if !apiManager.isConnectedToNetwork() {
            Utility.shared.alert(message: ErrorMessage.networkError, isLong: false)
            return
        }
        
        let params = ["username": userName, "password": password]
        print("Login Params: ", params)
        
        AF.request(
            ApiManager.Api.LOGIN,
            method: .post,
            parameters: params,
            encoding: URLEncoding.default // For application/x-www-form-urlencoded encoding
        ).responseData { (response) in
            debugPrint(response)
            
            // Check the HTTP status code
            if let statusCode = response.response?.statusCode {
                switch statusCode {
                case 200...299:
                    // Success: Decode the response data
                    if let data = response.data {
                        do {
                            let decoder = JSONDecoder()
                            let responseData = try decoder.decode(LoginResponse.self, from: data)
                            self.loggedInInfo = responseData
                            
                            print()
                            completion(true, responseData)
                        } catch {
                            print("Decoding error: \(error)")
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                    
                case 400...499:
                    // Client error (e.g., 422 Unprocessable Entity)
                    print("Client error with status code: \(statusCode)")
                    completion(false, nil)
                    
                case 500...599:
                    // Server error
                    print("Server error with status code: \(statusCode)")
                    completion(false, nil)
                    
                default:
                    // Other status codes
                    print("Unexpected status code: \(statusCode)")
                    completion(false, nil)
                }
            } else {
                print("Failed to get response status code.")
                completion(false, nil)
            }
        }
    }
    
    func performSignUp(name: String, password: String, confirmPassword: String, email: String, completion: @escaping (SignUpResponse?) -> ()) {
        let apiManager = ApiManager.shared
        
        if !apiManager.isConnectedToNetwork() {
            Utility.shared.alert(message: ErrorMessage.networkError, isLong: false)
            return
        }
        
        let params = [
            "name": name,
            "email": email,
            "password": password,
            "repeat_password": confirmPassword,
            "device_id": deviceId ?? "unavailable",
            "device_type": deviceType
        ]
        
        AF.request(
            ApiManager.Api.SIGN_UP,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers:  nil
        ).responseData { (response) in
            debugPrint(response)
            
            // Check the HTTP status code
            if let statusCode = response.response?.statusCode {
                switch statusCode {
                case 200...299:
                    // Success: Decode the response data
                    if let data = response.data {
                        do {
                            let decoder = JSONDecoder()
                            let responseData = try decoder.decode(SignUpResponse.self, from: data)
                            completion(responseData)
                        } catch {
                            print("Decoding error: \(error)")
                            completion(nil)
                        }
                    } else {
                        print("No data received.")
                        completion(nil)
                    }
                    
                case 400...499:
                    // Client error (e.g., invalid input, missing parameters)
                    print("Client error with status code: \(statusCode)")
                    if let data = response.data {
                        // Optionally, parse the error response data if needed
                        print("Error response: \(String(data: data, encoding: .utf8) ?? "Unknown error")")
                    }
                    completion(nil)
                    
                case 500...599:
                    // Server error
                    print("Server error with status code: \(statusCode)")
                    completion(nil)
                    
                default:
                    // Other status codes
                    print("Unexpected status code: \(statusCode)")
                    completion(nil)
                }
            } else {
                print("Failed to get response status code.")
                completion(nil)
            }
        }
    }
    
    
    func sendChatMessage(message: ConversationItem, completion: @escaping(ChatResponse?) -> ()) {
        let apiManager = ApiManager.shared
        
        if !apiManager.isConnectedToNetwork() {
            Utility.shared.alert(message: ErrorMessage.networkError, isLong: false)
            return
        }
        
        let params = [
            "user_id": message.userId ?? "",
            "conversation_id": message.conversationId ?? "",
            "request_id": message.requestId ?? "",
            "device_id": message.deviceId ?? "",
            "subscription": message.subscription ?? false,
            "message": message.message ?? "",
            "adapter_id": message.adapterId ?? ""
        ] as [String : Any]
        
        AF.request(
            ApiManager.Api.SEND_CHAT_MESSAGE,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers:  nil
        ).responseData { (response) in
            debugPrint(response)
            
            // Check the HTTP status code
            if let statusCode = response.response?.statusCode {
                switch statusCode {
                case 200...299:
                    // Success: Decode the response data
                    if let data = response.data {
                        do {
                            let decoder = JSONDecoder()
                            let responseData = try decoder.decode(ChatResponse.self, from: data)
                            completion(responseData)
                        } catch {
                            print("Decoding error: \(error)")
                            completion(nil)
                        }
                    } else {
                        print("No data received.")
                        completion(nil)
                    }
                    
                case 400...499:
                    // Client error (e.g., invalid input, missing parameters)
                    print("Client error with status code: \(statusCode)")
                    if let data = response.data {
                        // Optionally, parse the error response data if needed
                        print("Error response: \(String(data: data, encoding: .utf8) ?? "Unknown error")")
                    }
                    completion(nil)
                    
                case 500...599:
                    // Server error
                    print("Server error with status code: \(statusCode)")
                    completion(nil)
                    
                default:
                    // Other status codes
                    print("Unexpected status code: \(statusCode)")
                    completion(nil)
                }
            } else {
                print("Failed to get response status code.")
                completion(nil)
            }
        }
    }
    
    func forgotPassword(withUserName userName:String, completion:@escaping (Bool, String?) -> ()) {
        let link = Api.FORGOT_PASSWORD + "?email=" + userName
        print("forgotPassword link", link)
        ///*,"grant_type":"password"*/,"Device":DeviceInfo.type, "DeviceName":DeviceInfo.model,"DeviceId":DeviceInfo.identifier]
        AF.request(
            link,
            method: .post,
            headers: nil) .responseData { (response) in
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 200...299:
                        // Success: Decode the response data
                        if let data = response.data {
                            do {
                                let decoder = JSONDecoder()
                                let responseData = try decoder.decode(ForgotPassword.self, from: data)
                                completion(true, responseData.message)
                            } catch {
                                print("Decoding error: \(error)")
                                completion(false, error.localizedDescription)
                            }
                        } else {
                            print("No data received.")
                            completion (false, "No data recieved")
                        }
                        
                    case 400...499:
                        // Client error (e.g., invalid input, missing parameters)
                        print("Client error with status code: \(statusCode)")
                        var dataResponse:Data!
                        if let data = response.data {
                            // Optionally, parse the error response data if needed
                            dataResponse = data
                            print("Error response: \(String(data: data, encoding: .utf8) ?? "Unknown error")")
                        }
                        
                        completion(false, "\(String(data: dataResponse, encoding: .utf8) ?? "Unknown error")")
                        
                    case 500...599:
                        // Server error
                        print("Server error with status code: \(statusCode)")
                        completion(false, "Server Error")
                        
                    default:
                        // Other status codes
                        print("Unexpected status code: \(statusCode)")
                        completion(false, "Unexpected status code: \(statusCode)")
                    }
                } else {
                    print("Failed to get response status code.")
                    completion(false, "Failed to get response status code.")
                }
            }
    }
    
    func deleteAccount(withUserName userName:String, completion:@escaping (Bool, String?) -> ()) {
        
        ///*,"grant_type":"password"*/,"Device":DeviceInfo.type, "DeviceName":DeviceInfo.model,"DeviceId":DeviceInfo.identifier]
        //let params = ["user":UserDefaultsUtility.shared.email] as [String: String]
        AF.request(
            Api.DELETE,
            method: .delete,
            // parameters: params,
            // encoding: JSONEncoding.default,
            headers: getHeader()!) .responseData { (response) in
                // print(response.result)
                
                // Check the HTTP status code
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 200...299:
                        // Success: Decode the response data
                        if let data = response.data {
                            do {
                                let decoder = JSONDecoder()
                                let responseData = try decoder.decode(ForgotPassword.self, from: data)
                                completion(true, responseData.message)
                            } catch {
                                print("Decoding error: \(error)")
                                completion(false, error.localizedDescription)
                            }
                        } else {
                            print("No data received.")
                            completion (false, "No data recieved")
                        }
                        
                    case 400...499:
                        // Client error (e.g., invalid input, missing parameters)
                        print("Client error with status code: \(statusCode)")
                        var dataResponse:Data!
                        if let data = response.data {
                            // Optionally, parse the error response data if needed
                            dataResponse = data
                            print("Error response: \(String(data: data, encoding: .utf8) ?? "Unknown error")")
                        }
                        
                        completion(false, "\(String(data: dataResponse, encoding: .utf8) ?? "Unknown error")")
                        
                    case 500...599:
                        // Server error
                        print("Server error with status code: \(statusCode)")
                        completion(false, "Server Error")
                        
                    default:
                        // Other status codes
                        print("Unexpected status code: \(statusCode)")
                        completion(false, "Unexpected status code: \(statusCode)")
                    }
                } else {
                    print("Failed to get response status code.")
                    completion(false, "Failed to get response status code.")
                }
            }
    }
    
    func uploadPDF(fileURL: URL, userId: Int, adapterName: String, completion: @escaping (Bool, UploadResponse?) -> Void) {
        let url = Api.UPLOAD_DOCUMENT + "?adapter_name=\(adapterName)&user_id=\(userId)"
        
        if !isConnectedToNetwork() {
            Utility.shared.alert(message: ErrorMessage.networkError, isLong: false)
            return
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileURL, withName: "file", fileName: fileURL.lastPathComponent, mimeType: "application/pdf")
        }, to: url).responseData(completionHandler: { response in
            
            if let statusCode = response.response?.statusCode {
                switch statusCode {
                case 200...299:
                    if let data = response.data {
                        do {
                            let decoder = JSONDecoder()
                            let responseData = try decoder.decode(UploadResponse.self, from: data)
                            completion(true, responseData)
                        } catch {
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                    
                case 400...499:
                    completion(false, nil)
                    
                case 500...599:
                    completion(false, nil)
                    
                default:
                    completion(false, nil)
                }
                
            } else {
                completion(false, nil)
            }
            
        })
    }
    
    func checkTaskStatus(userId: Int, taskId: Int, completion: @escaping (Bool, ProgressResponse?) -> Void) {
        let url = Api.UPLOAD_STATUS + "\(userId)/\(taskId)"
        
        AF.request(
            url,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers:  nil
        ).responseData { (response) in
            
            debugPrint(response)
            
            if let statusCode = response.response?.statusCode {
                switch statusCode {
                case 200...299:
                    if let data = response.data {
                        do {
                            let decoder = JSONDecoder()
                            let responseData = try decoder.decode(ProgressResponse.self, from: data)
                            completion(true, responseData)
                        } catch {
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                    
                case 400...499:
                    completion(false, nil)
                    
                case 500...599:
                    completion(false, nil)
                    
                default:
                    completion(false, nil)
                }
                
            } else {
                completion(false, nil)
            }
            
        }
    }
    
    func getJobIds(userId: Int, completion: @escaping (Bool, AdapterResponse? ) -> Void) {
        let url = Api.ADAPTER_LIST + "\(userId)"
        
        AF.request(
            url,
            method: .post,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers:  nil
        ).responseData { (response) in
            print("Printing Response")
            debugPrint(response)
            
            if let statusCode = response.response?.statusCode {
                switch statusCode {
                case 200...299:
                    if let data = response.data {
                        do {
                            let decoder = JSONDecoder()
                            let responseData = try decoder.decode(AdapterResponse.self, from: data)
                            completion(true, responseData)
                        } catch {
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                    
                case 400...499:
                    completion(false, nil)
                    
                case 500...599:
                    completion(false, nil)
                    
                default:
                    completion(false, nil)
                }
                
            } else {
                completion(false, nil)
            }
            
        }
    }
    
}
