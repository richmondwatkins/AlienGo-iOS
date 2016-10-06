//
//  RedditPostListingViewModel.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol RedditPostListingViewModelDelegate {
    func displayRedditPosts(posts: [DisplayableFeedItem])
}

protocol RedditPostListingNavigationDelegate {
    func display(vc: DetailViewController)
}
class RedditPostListingViewModel: NSObject {

    lazy var readHandler: ReadableDelegate = ReadHandler()
    private var isFirstLoad: Bool = true
    @IBOutlet weak var collectionSource: MainCollectionViewSource! {
        didSet {
            collectionSource.set(selectionDelegate: self)
            displayDelegate = collectionSource
        }
    }
    
    var displayDelegate: RedditPostListingViewModelDelegate! {
        didSet {
            getPosts()
        }
    }
    lazy var postProvider: RedditPostProvider = RedditPostProvider()
    var navigationDelegate: RedditPostListingNavigationDelegate!
    
    // For storyboard object
    override init() {
        super.init()
    }

    func getDetailViewModel(detailViewController: DetailViewController) -> DetailViewModel {
        readHandler.stopIfNeeded()
        return DetailViewModel(detailPostItem: DetailPost(displayableFeedItem: collectionSource.getCurrentPost()), displayDelegate: detailViewController)
    }
    
    func getPosts() {
        DispatchQueue.global(qos: .userInitiated).async {
            let posts = self.postProvider.get()
            self.displayDelegate.displayRedditPosts(posts: self.postProvider.get())
            
            if self.isFirstLoad && posts.count > 0 {
                self.readHandler.readItem(prefixText: "First Post", readableItem: RedditReadablePost(displayablePost: posts[0]))
                self.isFirstLoad = false
            }
        }
    }
}

extension RedditPostListingViewModel: MainCollectionSourceSelectionDelegate {
    func readPostTitle(post: RedditReadablePost, scrollDirection: ScrollDirection) {
        var prefixText = "Next Post"
        
        if scrollDirection == .up {
            prefixText = "Previous Post"
            
        }
        
        readHandler.readItem(prefixText: prefixText, readableItem: post)
    }

    func didSelect(post: DisplayableFeedItem) {
        readHandler.stopIfNeeded()
    }
}
