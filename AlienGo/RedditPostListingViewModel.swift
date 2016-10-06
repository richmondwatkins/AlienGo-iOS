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

    lazy var readHandler: ReadHandler = ReadHandler()
    @IBOutlet weak var collectionSource: MainCollectionViewSource! {
        didSet {
            collectionSource.set(readableDelegate: readHandler)
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
            self.displayDelegate.displayRedditPosts(posts: self.postProvider.get())
        }
    }
}

extension RedditPostListingViewModel: MainCollectionSourceSelectionDelegate {
    func didSelect(post: DisplayableFeedItem) {
        readHandler.stopIfNeeded()
    }
}
