//
//  RAAuthWebViewController.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/16/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class RAAuthWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView! {
        didSet {
            webView.delegate = self
        }
    }
    
    let state: String = UUID().uuidString
    let scope: String = "identity,history,mysubreddits,read,report,save,vote"
    
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
            NetworkManager.shared.getRedditUsername(callback: { [weak self] (response, error) in
                if let username = response?["name"] as? String {
                    UserInfo.username = username
                }
                
                ((UIApplication.shared).delegate as! AppDelegate).subredditRepository.storeSubscriptions()
                
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
