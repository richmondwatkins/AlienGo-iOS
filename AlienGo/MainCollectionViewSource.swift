//
//  MainCollectionViewSource.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

enum ScrollDirection {
    case up, down, first
    
    init(previousPage: Int, newPage: Int) {
        if previousPage == 0 && newPage == 0 {
            self = .first
        } else if previousPage > newPage {
            self = .up
        } else {
            self = .down
        }
    }
}

protocol MainCollectionSourceSelectionDelegate {
    func didSelect(post: DisplayableFeedItem)
    func didStartToPan()
    func readPostTitle(post: RedditReadablePost, scrollDirection: ScrollDirection, cell: MainCollectionViewCell)
    func loadMore()
    func refresh()
}

class MainCollectionViewSource: NSObject {

    fileprivate lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = UIColor(ColorConstants.appBlue)
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return control
    }()
    @IBOutlet weak var collectionView: MainCollectionView! {
        didSet {
            let cellClassName = String(describing: MainCollectionViewCell.self)
            collectionView.register(UINib(nibName: cellClassName, bundle: Bundle.main), forCellWithReuseIdentifier: cellClassName)
            collectionView.addSubview(refreshControl)
            collectionView.alwaysBounceVertical = true
        }
    }
    var currentPage: Int = 0
    var pagesLoaded: [Int] = []
    fileprivate var data: [DisplayableFeedItem] = []
    fileprivate var selectionDelegate: MainCollectionSourceSelectionDelegate!
    fileprivate var firstLoad: Bool = true
    private var userScrolling: Bool = false
    
    fileprivate func set(data: [DisplayableFeedItem]) {
        self.data = data
        collectionView?.reloadData()
    }
    
    func refresh() {
        self.collectionView.setContentOffset(self.collectionView.contentOffset, animated: true)
        selectionDelegate.refresh()
    }
    
    func getData() -> [DisplayableFeedItem] {
        return data
    }
    
    func insert(data: [DisplayableFeedItem]) {
        self.data.append(contentsOf: data)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func goToNextPage() {
        if !userScrolling {
            DispatchQueue.main.async {
                self.currentPage += 1
                self.collectionView.scrollToItem(at: IndexPath(row: self.currentPage, section: 0), at: .centeredVertically, animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.callDelegates(previousPage: self.currentPage - 1)
                })
            }
        }
    }
    
    func set(selectionDelegate: MainCollectionSourceSelectionDelegate) {
        self.selectionDelegate = selectionDelegate
    }

    func getCurrentPost() -> DisplayableFeedItem? {
        if currentPage < data.count {
            return data[currentPage]
        }
        
        return nil
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        userScrolling = true
        selectionDelegate.didStartToPan()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if collectionView != nil && collectionView.frame.height > 0 {
            let previousPage = currentPage
            currentPage = Int(self.collectionView.contentOffset.y / self.collectionView.frame.height)
            
            if previousPage != currentPage {
              callDelegates(previousPage: previousPage)
            }
        }
        
        userScrolling = false
    }
    
    func callDelegates(previousPage: Int) {
        if let currentPost = getCurrentPost(), let cell = self.collectionView.cellForItem(at: IndexPath(row: currentPage, section: 0)) as? MainCollectionViewCell {
            selectionDelegate.readPostTitle(post: RedditReadablePost(displayablePost: currentPost), scrollDirection: ScrollDirection(previousPage: previousPage, newPage: currentPage), cell:  cell)
        }
    }
}

extension MainCollectionViewSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MainCollectionViewCell.self), for: indexPath) as! MainCollectionViewCell
        
        cell.configure(post: data[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
}


extension MainCollectionViewSource: RedditPostListingViewModelDelegate {
    internal func animateRefreshControl() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }

    internal func displayRedditPosts(posts: [DisplayableFeedItem]) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            self.set(data: posts)
            self.collectionView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
}


extension MainCollectionViewSource: UICollectionViewDelegate {
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectionDelegate.didSelect(post: data[indexPath.row])
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if firstLoad {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.callDelegates(previousPage: 0)
                self.firstLoad = false
            })
        }
        
        let page = data.count / 25
        
        if indexPath.row == data.count - 5 && !pagesLoaded.contains(page) {
            selectionDelegate.loadMore()
            pagesLoaded.append(page)
        }
    }
}

extension MainCollectionViewSource: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
