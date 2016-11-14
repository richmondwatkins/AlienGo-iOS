//
//  HTTPClient.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/13/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import Alamofire

public typealias Parameters = NSDictionary
public typealias Headers = [String : String]

enum HTTPMethod: String {
    case get = "GET", post = "POST", put = "PUT", patch = "PATCH", delete = "DELETE"
}

struct HTTPClient {
    
    let request: URLRequest
    
    init(method: HTTPMethod, url: URL, headers: Headers? = nil, paramters: Parameters? = nil) {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method.rawValue
        
        headers?.forEach({ (k, v) in
            request.setValue(v, forHTTPHeaderField: k)
        })
        
        if let params = paramters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .init(rawValue: 0))
        }
        
        self.request = request.copy() as! URLRequest
    }
    
    static func request(method: HTTPMethod, url: URL, headers: Headers? = nil, paramters: Parameters? = nil) -> HTTPClient {
        return HTTPClient(method: method, url: url, headers: headers, paramters: paramters)
    }
    
    func response(_ completion: @escaping (Any?, Error?) -> Void) {
        Alamofire.request(self.request).responseJSON { (response) in
            completion(response.result.value, response.result.error)
        }
    }
}
