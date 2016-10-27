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
    func animateRefreshControl()
}

protocol RedditPostListingNavigationDelegate {
    func displayDetailVC()
    func didFinishReadingAfterSwipe(direction: ScrollDirection)
}
class RedditPostListingViewModel: NSObject {

    lazy var readHandler: ReadableDelegate = ReadHandler.shared
    private var isFirstLoad: Bool = true
    private var shouldAcceptLongPress: Bool = true
    @IBOutlet weak var collectionSource: MainCollectionViewSource! {
        didSet {
            collectionSource.set(selectionDelegate: self)
            displayDelegate = collectionSource
        }
    }
    var currentSubreddit = Subreddit(name: "front")
    var displayDelegate: RedditPostListingViewModelDelegate! {
        didSet {
           getPostsFor(subreddit: Subreddit(name: "front"))
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
    
    func readFirst() {
       collectionSource.callDelegates(previousPage: 0)
    }
    
    func reReadCurrent(press: UILongPressGestureRecognizer) {
        if press.state == .began && shouldAcceptLongPress {
            readHandler.reReadCurrent()
            shouldAcceptLongPress = false
        } else if press.state == .ended {
            shouldAcceptLongPress = true
        }
    }
    
    func getPostsFor(subreddit: Subreddit) {
        displayDelegate.animateRefreshControl()
        self.currentSubreddit = subreddit
        DispatchQueue.global(qos: .userInitiated).async {
            self.displayDelegate.displayRedditPosts(posts: self.postProvider.getPostsFor(subreddit: subreddit))
        }
    }

    func getDetailViewModel(detailViewController: DetailViewController) -> DetailViewModel {
        readHandler.stop()
        return MainDetailViewModel(detailPostItem: DetailPost(displayableFeedItem: collectionSource.getCurrentPost()), displayDelegate: detailViewController)
    }
}

extension RedditPostListingViewModel: MainCollectionSourceSelectionDelegate {
    func readPostTitle(post: RedditReadablePost, scrollDirection: ScrollDirection, cell: MainCollectionViewCell) {
        if UserDefaults.standard.bool(forKey: "shouldStartReading") {
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
            
            readHandler.readItem(readableItem: ReaderContainer(text: prefixText), delegate: nil) {
                self.readHandler.readItem(readableItem: post, delegate: cell, completion: {
                    if StateProvider.isAuto {
                        self.navigationDelegate.displayDetailVC()
                    }
                    
                    if scrollDirection != .first {
                        self.navigationDelegate.didFinishReadingAfterSwipe(direction: scrollDirection)
                    }
                })
            }
        }
    }
    
    func didStartToPan() {
        if StateProvider.isAuto {
            readHandler.hardStop()
        }
    }

    func didSelect(post: DisplayableFeedItem) {
        readHandler.stop()
    }
    
    func refresh() {
        
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

extension RedditPostListingViewModel: ActionDelegate {
    
    func showFrontPage() {
        getPostsFor(subreddit: Subreddit(name: "front"))
    }
    
    func showAll() {
        getPostsFor(subreddit: Subreddit(name: "all"))
    }
}

