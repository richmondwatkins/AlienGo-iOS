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
    
    func getDetailInfo(detailPostItem: DetailPostItem, callback: NetworkCallback?) {
        let url: URL = URL(string: "http://localhost:3000/parse")!
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        
        guard let bodyContent = detailPostItem.content.requestBodyValue() else {
            return
        }
        
        Alamofire.request(url, method: .post, parameters: ["html": bodyContent], encoding: JSONEncoding.default).responseJSON { (response) in
            if response.result.isSuccess, let value = response.result.value as AnyObject? {
                callback?(value as AnyObject?, nil)
            } else {
                callback?(nil, response.result.error)
            }
        }
    }
    
    private func sendRequest(request: URLRequest, callback: NetworkCallback?) {

        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        session.dataTask(with: request) {(data, response, error) -> Void in
            if let data = data {
                print(data)
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                    callback?(json as AnyObject?, error)
                } else {
                    callback?(nil, error)
                }
            }
        }.resume()
    }
}
