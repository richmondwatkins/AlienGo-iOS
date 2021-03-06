//
//  RedditPostListingViewModel.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol RedditPostListingViewModelDelegate: class {
    func displayRedditPosts(posts: [DisplayableFeedItem])
    func animateRefreshControl()
}

protocol RedditPostListingNavigationDelegate: class {
    func displayDetailVC()
    func didFinishReadingAfterSwipe(direction: ScrollDirection)
    func showingCategory(category: Category)
    func loading()
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
    var currentSubreddit = Category(name: "front")
    weak var displayDelegate: RedditPostListingViewModelDelegate?
    var postProvider: RedditPostProvider = RedditPostProvider(repository: MainNewsRepository())
    weak var navigationDelegate: RedditPostListingNavigationDelegate?
    
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
    
    func getPostsFor(subreddit: Category) {
        displayDelegate?.animateRefreshControl()
        self.currentSubreddit = subreddit
        DispatchQueue.global(qos: .userInitiated).async {
            let posts = self.postProvider.getPostsFor(subreddit: subreddit)
            self.displayDelegate?.displayRedditPosts(posts: posts)
            
            self.navigationDelegate?.showingCategory(category: self.currentSubreddit)
        }
    }
    
    func didSelect() {
        readHandler.hardStop()
    }

    func getDetailViewModel(detailViewController: DetailViewController) -> DetailViewModel? {
        if let currentPost = collectionSource.getCurrentPost() {
            readHandler.stop()
            return MainDetailViewModel(detailPostItem: DetailPost(displayableFeedItem: currentPost), displayDelegate: detailViewController)
        }
        
        return nil
    }
}

extension RedditPostListingViewModel: MainCollectionSourceSelectionDelegate {
    func readPostTitle(post: RedditReadablePost, scrollDirection: ScrollDirection, cell: MainCollectionViewCell) {
        guard UserAppState.shouldStartReading else { return }
        
        self.readHandler.hardStop()
        
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
        
        let readingId = post.postId
        readHandler.readItem(readableItem: ReaderContainer(text: prefixText), delegate: nil) {
            self.readHandler.readItem(readableItem: post, delegate: cell, completion: {
                if StateProvider.isAuto && readingId == self.collectionSource.getCurrentPost()?.postId {
                    self.navigationDelegate?.displayDetailVC()
                }
                
                if scrollDirection != .first {
                    self.navigationDelegate?.didFinishReadingAfterSwipe(direction: scrollDirection)
                }
            })
        }
    }
    
    func didStartToPan() {
        if StateProvider.isAuto {
            readHandler.hardStop()
        }
    }

    func didSelect(post: DisplayableFeedItem) {
        guard UserAppState.shouldStartReading else { return }
        
        readHandler.stop()
    }
    
    func refresh() {
        getPostsFor(subreddit: currentSubreddit)
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
    func show(subreddit: Category) {
        show(category: subreddit)
    }

    func showFrontPage() {
        show(subreddit: Category(name: "front"))
    }
    
    func showAll() {
        show(subreddit: Category(name: "all"))
    }
    
    func show(category: Category) {
        readHandler.hardStop()

        getPostsFor(subreddit: category)
        
        navigationDelegate?.loading()
    }
}

