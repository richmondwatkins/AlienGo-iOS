//
//  NYTRequestOperation.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/30/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import Alamofire

typealias NYTRequestCallback = ((_ result: [String: AnyObject]?, _ success: Bool) -> Void)
private let apiKey = "a3f30dae83784c5d9cd01617d197dae1"

class NYTRequestOperation: Operation {

    let callback: NYTRequestCallback
    let category: Category
    
    init(category: Category, callback: @escaping NYTRequestCallback) {
        self.category = category
        self.callback = callback
    }
    
    override func main() {
        super.main()
        
        let sem = DispatchSemaphore(value: 0)
        
        let request = URLRequest(url: URL(string: "https://api.nytimes.com/svc/topstories/v2/\(category.name).json?api-key=\(apiKey)")!)
        
        Alamofire.request(request).responseJSON(completionHandler: { [unowned self] (response) in
            self.callback(response.result.value as! [String : AnyObject]?, response.result.isSuccess)
            sem.signal()

        })
        
        sem.wait()
    }
}
