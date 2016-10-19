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

class NetworkManager: NSObject {

    static let shared: NetworkManager = NetworkManager()
    
    func getRedditPosts(callback: NetworkCallback?) {
        let url: URL = URL(string: "https://www.reddit.com/r/all/.json")!
        
        sendRequest(request: URLRequest(url: url), callback: callback)
    }
    
    func getRedditPostsAtPage(lastPostId: String, totalPostCount: Int, callback: @escaping NetworkCallback) {
        //https://www.reddit.com/r/all/.json?count=25&after=t3_5656e1.json
        let url: URL = URL(string: "https://www.reddit.com/r/all/.json?count=\(totalPostCount)&after=\(lastPostId)")!
        
        sendRequest(request: URLRequest(url: url), callback: callback)
    }
    
    func getCommentsForPost(permalink: String, callback: @escaping NetworkCallback) {
        //https://www.reddit.com/r/pics/comments/5658ox/how_to_cable/.json
        let url: URL = URL(string: "https://www.reddit.com\(permalink).json")!

        sendRequest(request: URLRequest(url: url), callback: callback)
    }
    
    func getRedditUsername(callback: NetworkCallback?) {
        Alamofire.request( URL(string: "https://oauth.reddit.com/api/v1/me")!, method: .get, parameters: nil, headers: ["Authorization": "bearer \(AuthInfo.accessToken ?? "")"]).responseJSON { (response) in
            if let result = response.result.value, response.result.isSuccess {
                callback?(result as AnyObject?, nil)
            } else {
                callback?(nil, response.result.error)
            }
        }
    }
    
    func getRedditAccessToken(code: String, callback: @escaping NetworkCallback) {
        //https://www.reddit.com/api/v1/access_token

        Alamofire.request("https://www.reddit.com/api/v1/access_token", method: .post, parameters: ["grant_type": "authorization_code", "code": code, "redirect_uri": redirectUri], encoding: URLEncoding.default).authenticate(user: clientId, password: "").responseJSON { (response) in
            if response.result.isSuccess, let value = response.result.value as AnyObject? {
                callback(value as AnyObject?, nil)
            } else {
                callback(nil, response.result.error)
            }
        }
    }
    
    func postDetailInfo(detailPostItem: DetailPostItem, bodyContent: String,  callback: NetworkCallback?) {
        let url: URL = URL(string: "http://lowcost-env.pcwzrxfsmz.us-east-1.elasticbeanstalk.com/update")!

        Alamofire.request(url, method: .post, parameters: ["content": bodyContent, "postId": detailPostItem.id], encoding: JSONEncoding.default).responseJSON { (response) in
            if response.result.isSuccess, let value = response.result.value as AnyObject? {
                callback?(value as AnyObject?, nil)
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
        
        Alamofire.request(url, method: .post, parameters: ["html": bodyContent, "postId": detailPostItem.id], encoding: JSONEncoding.default).responseJSON { (response) in
            if response.result.isSuccess, let value = response.result.value as AnyObject? {
                callback?(value as AnyObject?, nil)
            } else {
                callback?(nil, response.result.error)
            }
        }
    }
    
    private func appendRedditAuth(request: URLRequest) -> URLRequest {
        var requestVal = request

        print("bearer \(AuthInfo.accessToken ?? "")")
        requestVal.setValue("bearer \(AuthInfo.accessToken ?? "")", forHTTPHeaderField: "Authorization")

        return request
    }
    
    
    private func sendRequest(request: URLRequest, callback: NetworkCallback?) {

        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        session.dataTask(with: request) {(data, response, error) -> Void in
            if let data = data {
                print(data)
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                print(json)
                if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                    callback?(json as AnyObject?, error)
                } else {
                    callback?(nil, error)
                }
            }
        }.resume()
    }
}
