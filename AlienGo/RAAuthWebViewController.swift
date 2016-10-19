//
//  RAAuthWebViewController.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/16/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

let clientId: String = "KDXXXxZltF-RMA"
let redirectUri: String = "alienreader://com.alienreader.app/oauth"

class RAAuthWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView! {
        didSet {
            webView.delegate = self
        }
    }
    
    let state: String = UUID().uuidString
    let scope: String = "identity,mysubreddits,vote"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authUrl: String = "https://www.reddit.com/api/v1/authorize.compact?client_id=\(clientId)&response_type=code&state=\(state)&redirect_uri=\(redirectUri)&duration=permanent&scope=\(scope)"
        
        webView.loadRequest(URLRequest(url: URL(string: authUrl)!))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRecieveCode(notification:)), name: NSNotification.Name(rawValue: notificationAuthCodeReceived), object: nil)
    }
    
    func didRecieveCode(notification: Notification) {
        NetworkManager.shared.getRedditAccessToken(code: notification.userInfo?["code"] as! String, callback: { (response, error) in
            AuthInfo.accessToken = response?["access_token"] as? String
            AuthInfo.refreshToken = response?["refresh_token"] as? String
            
            NetworkManager.shared.getRedditUsername(callback: { [weak self] (response, error) in
                if let username = response?["name"] as? String {
                    UserInfo.username = username
                }
                
                let _ = self?.navigationController?.popViewController(animated: true)
            })
        })
    }
}

extension RAAuthWebViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        //
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.absoluteString == "https://www.reddit.com/api/v1/authorize" {
           //let _ = self.navigationController?.popViewController(animated: true)
        }
        
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        //
    }
}
