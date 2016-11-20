//
//  NetworkManager.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import Alamofire

typealias NetworkCallback = (_ data: AnyObject?, _ error: Error?) -> Void
typealias NetworkCall = (request: URLRequest, callback: NetworkCallback?)

class NetworkManager: NSObject {

    static let shared: NetworkManager = NetworkManager()
    
    var urlDomainPrefix: String {
        if let _ = AuthInfo.accessToken, let _ = AuthInfo.refreshToken {
            return "https://oauth.reddit.com"
        }
        
        return "https://www.reddit.com"
    }
    var queuedRequests: [NetworkCall] = []
    
    func getPostsForSubreddit(subreddit: Category, callback: NetworkCallback?) {
        
        let url: URL = URL(string: "\(urlDomainPrefix)\(subreddit.urlPath)")!
        var request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
       
        request = setReadditHeaders(request: request)
        
        sendRequest(request: request as URLRequest, callback: callback)
    }
    
    func getDefaultSubreddits(callback: @escaping NetworkCallback) {
        let url: URL = URL(string: "https://www.reddit.com/subreddits/default.json")!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        sendRequest(request: request as URLRequest, callback: callback)
    }
    
    func getRedditPostsAtPage(lastPostId: String, totalPostCount: Int, callback: @escaping NetworkCallback) {
        //https://www.reddit.com/r/all/.json?count=25&after=t3_5656e1.json
        let url: URL = URL(string: "\(urlDomainPrefix)/r/all/.json?count=\(totalPostCount)&after=\(lastPostId)")!
        
        sendRequest(request: URLRequest(url: url), callback: callback)
    }
    
    func getCommentsForPost(permalink: String, callback: @escaping NetworkCallback) {
        //https://www.reddit.com/r/pics/comments/5658ox/how_to_cable/.json
        let url: URL = URL(string: "\(urlDomainPrefix)\(permalink).json")!

        sendRequest(request: URLRequest(url: url), callback: callback)
    }
    
    func getRedditUsername(callback: NetworkCallback?) {
        let url: URL = URL(string: "https://oauth.reddit.com/api/v1/me")!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        sendRequest(request: setReadditHeaders(request: request) as URLRequest, callback: callback)
    }
    
    func getRedditAccessToken(code: String, callback: NetworkCallback?) {
        //https://www.reddit.com/api/v1/access_token

        getAccessToken(paramaters: ["grant_type": "authorization_code", "code": code, "redirect_uri": redirectUri], callback: callback)
    }
    
    func getRedditAccessToken(refreshToken: String, callback: NetworkCallback?) {
        //https://www.reddit.com/api/v1/access_token
        
        getAccessToken(paramaters: ["grant_type": "refresh_token", "refresh_token": refreshToken], callback: callback)
    }
    
    func reportPost(postId: String) {
        let url: URL = URL(string: "http://lowcost-env.pcwzrxfsmz.us-east-1.elasticbeanstalk.com/report")!
        var request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        
        request = setReadditHeaders(request: request)
        
        sendRequest(request: request as URLRequest, callback: nil)
    }
    
    private func getAccessToken(paramaters: [String: String], callback: NetworkCallback?) {
        Alamofire.request("https://www.reddit.com/api/v1/access_token", method: .post, parameters: paramaters, encoding: URLEncoding.default).authenticate(user: clientId, password: "").responseJSON { (response) in
            if response.result.isSuccess, let value = response.result.value as AnyObject? {
                print(value)
                AuthInfo.accessToken = value["access_token"] as? String
                AuthInfo.refreshToken = value["refresh_token"] as? String
                
                self.emptyQueuedCalls()
                
                callback?(value, nil)
            } else {
                callback?(nil, response.result.error)
            }
        }
    }
    
    func getDetailInfo(detailPostItem: DetailPostItem, callback: NetworkCallback?) {
        let url: URL = URL(string: "http://lowcost-env.pcwzrxfsmz.us-east-1.elasticbeanstalk.com/parse")!
        
        guard let bodyContent = detailPostItem.content.requestBodyValue() else {
            return
        }
        
        Alamofire.request(url, method: .post, parameters:  ["html": bodyContent, "postId": detailPostItem.id], encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            callback?(response.result.value as AnyObject?, response.result.error)
        }
    }
    
    private func setReadditHeaders(request: NSMutableURLRequest) -> NSMutableURLRequest {
        if let accessToken = AuthInfo.accessToken, let _ = AuthInfo.refreshToken {
            request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
    
    private func sendRequest(request: URLRequest, callback: NetworkCallback?) {
        Alamofire.request(request).responseJSON { (response) in
            if let result = response.result.value as AnyObject? {
                if let errorCode = result["error"] as? Int, (errorCode == 401 || errorCode == 403) {
                    self.queuedRequests.append((request: request, callback: callback))
                    if let refreshToken = AuthInfo.refreshToken {
                        self.getRedditAccessToken(refreshToken: refreshToken, callback: nil)
                    }
                } else {
                    callback?(result, nil)
                }
            } else {
                callback?(nil, response.result.error)
            }
        }
    }
    
    private func emptyQueuedCalls() {
        queuedRequests.forEach { (networkCall) in
            sendRequest(request: networkCall.request, callback: networkCall.callback)
        }
        queuedRequests.removeAll()
    }
}
