//
//  MainCollectionViewSource.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol MainCollectionSourceSelectionDelegate {
    func didSelect(post: DisplayableFeedItem)
}

class MainCollectionViewSource: NSObject {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let cellClassName = String(describing: MainCollectionViewCell.self)
            collectionView.register(UINib(nibName: cellClassName, bundle: Bundle.main), forCellWithReuseIdentifier: cellClassName)
        }
    }
    var currentPage: Int = 0
    private var isFirstLoad: Bool = true
    fileprivate var data: [DisplayableFeedItem] = [] {
        didSet {
            if isFirstLoad && data.count > 0 {
                readableDelegate.readItem(prefixText: "First Post", readableItem: RedditReadablePost(displayablePost: data[0]))
                isFirstLoad = false
            }
        }
    }
    fileprivate var readableDelegate: ReadableDelegate!
    fileprivate var selectionDelegate: MainCollectionSourceSelectionDelegate!
    
    fileprivate func set(data: [DisplayableFeedItem]) {
        self.data = data
        collectionView?.reloadData()
    }
    
    func set(selectionDelegate: MainCollectionSourceSelectionDelegate) {
        self.selectionDelegate = selectionDelegate
    }
    
    func set(readableDelegate: ReadableDelegate) {
        self.readableDelegate = readableDelegate
    }
    
    func getCurrentPost() -> DisplayableFeedItem {
        return data[currentPage]
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if collectionView != nil && collectionView.frame.height > 0 {
            currentPage = Int(self.collectionView.contentOffset.y / self.collectionView.frame.height)
            
            readableDelegate.readItem(prefixText: "Next Post", readableItem:  RedditReadablePost(displayablePost: getCurrentPost()))
        }
    }
}

extension MainCollectionViewSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MainCollectionViewCell.self), for: indexPath) as! MainCollectionViewCell
        
        cell.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        
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
