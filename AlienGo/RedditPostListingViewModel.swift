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
    func displayDetailVC()
}
class RedditPostListingViewModel: NSObject {

    lazy var readHandler: ReadableDelegate = ReadHandler()
    private var isFirstLoad: Bool = true
    private var shouldAcceptLongPress: Bool = true
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
    
    func readAndShowNextPost() {
        collectionSource.goToNextPage()
    }
    
    func reReadCurrent(press: UILongPressGestureRecognizer) {
        if press.state == .began && shouldAcceptLongPress {
            readHandler.reReadCurrent()
            shouldAcceptLongPress = false
        } else if press.state == .ended {
            shouldAcceptLongPress = true
        }
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
    func readPostTitle( post: RedditReadablePost, scrollDirection: ScrollDirection) {
        var post = post
        var prefixText = ""
        
        switch scrollDirection {
        case .first:
            prefixText = "First Post"
        case .down:
            prefixText = "Next Post"
        case .up:
            prefixText = "Previous Post"
        }
        
        if let subbreddit = post.subredditName {
            prefixText += " in \(subbreddit)"
        }
        
        post.readCompletionHandler = {
            if StateProvider.isAuto {
                self.navigationDelegate.displayDetailVC()
            }
        }
        
        readHandler.readItem(prefixText: prefixText, readableItem: post)
    }

    func didSelect(post: DisplayableFeedItem) {
        readHandler.stopIfNeeded()
    }
    
    func didDisplay(post: DisplayableFeedItem, cell: MainCollectionViewCell) {
        readHandler.readingCallbackDelegate = cell
    }
    
    
    func refresh() {
        getPosts()
    }
    
    func loadMore() {
        DispatchQueue.global(qos: .userInitiated).async {
            let existingData = self.collectionSource.getData()
            if let lastPost = existingData.last {
                let nextPage = self.postProvider.loadMore(postId: lastPost.postName , totalCount: existingData.count)
                
                self.collectionSource.insert(data: nextPage)
            }
        }
    }
}
