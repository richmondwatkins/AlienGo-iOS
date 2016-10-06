//
//  RedditPostDetailRepository.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol DetailItem {
    var title: String { get }
}

typealias RedditPostDetailFetchCallback = (_ item: DetailItem) -> Void

class RedditPostDetailRepository {

    let detailPost: DetailPostItem
    
    init(detailPost: DetailPostItem) {
        self.detailPost = detailPost
    }
    
    func get(callback: @escaping  (_ textItem: DetailTextItem?) -> Void) {
        NetworkManager.shared.getDetailInfo(detailPostItem: detailPost) { (response, error) in
            guard let response = response, let content = response["content"] as? String else {
                return
            }
            
            callback(
                DetailTextContainer(
                    title: response["title"] as? String,
                    content: content
                )
            )
        }
    }
}
