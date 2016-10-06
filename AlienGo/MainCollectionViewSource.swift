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
    func didDisplay(post: DisplayableFeedItem, cell: MainCollectionViewCell)
    func readPostTitle(post: RedditReadablePost, scrollDirection: ScrollDirection)
    func loadMore()
}

class MainCollectionViewSource: NSObject {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let cellClassName = String(describing: MainCollectionViewCell.self)
            collectionView.register(UINib(nibName: cellClassName, bundle: Bundle.main), forCellWithReuseIdentifier: cellClassName)
        }
    }
    var currentPage: Int = 0
    var pagesLoaded: [Int] = []
    fileprivate var data: [DisplayableFeedItem] = []
    fileprivate var selectionDelegate: MainCollectionSourceSelectionDelegate!
    fileprivate var firstLoad: Bool = true
    
    fileprivate func set(data: [DisplayableFeedItem]) {
        self.data = data
        collectionView?.reloadData()
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
    
    func set(selectionDelegate: MainCollectionSourceSelectionDelegate) {
        self.selectionDelegate = selectionDelegate
    }

    func getCurrentPost() -> DisplayableFeedItem {
        return data[currentPage]
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if collectionView != nil && collectionView.frame.height > 0 {
            let previousPage = currentPage
            currentPage = Int(self.collectionView.contentOffset.y / self.collectionView.frame.height)
            
            if previousPage != currentPage {
              callDelegates(previousPage: previousPage)
            }
        }
    }
    
    func callDelegates(previousPage: Int) {
        selectionDelegate.didDisplay(
            post: getCurrentPost(),
            cell: self.collectionView.cellForItem(at: IndexPath(row: currentPage, section: 0)) as! MainCollectionViewCell
        )
        selectionDelegate.readPostTitle(post: RedditReadablePost(displayablePost: getCurrentPost()), scrollDirection: ScrollDirection(previousPage: previousPage, newPage: currentPage))
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
    internal func displayRedditPosts(posts: [DisplayableFeedItem]) {
        DispatchQueue.main.async {
            self.set(data: posts)
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
