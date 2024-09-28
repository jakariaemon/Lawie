//
//  CustomWebView.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/09/13.
//

import UIKit
import WebKit

class CustomWebView: BaseViewController, WKNavigationDelegate {
    @IBOutlet private weak var customWebView: WKWebView!
    var webViewLink: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customWebView.navigationDelegate = self
        loadWebsite()
    }
    
    func loadWebsite() {
           // Ensure the URL string is not nil and can be converted to a URL
           guard let urlString = webViewLink, let url = URL(string: urlString) else {
               print("Invalid URL string")
               return
           }
        
           // Create a URLRequest and load it in the web view
           let request = URLRequest(url: url)
           customWebView.load(request)
       }
    
    @IBAction private func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    

}
