//
//  DetailViewModel.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol DetailViewModelDelegate {
    func display(childVC: UIViewController)
}
struct DetailViewModel {

    let detailPostItem: DetailPostItem
    let displayDelegate: DetailViewModelDelegate
    var provider: RedditDetailPostProvider!
    private var readableDelegate: ReadableDelegate = ReadHandler()
    
    mutating func set(readableDelegate: ReadableDelegate) {
        self.readableDelegate = readableDelegate
    }
    
    init(detailPostItem: DetailPostItem, displayDelegate: DetailViewModelDelegate) {
        self.detailPostItem = detailPostItem
        provider = RedditDetailPostProvider(detailPost: detailPostItem)
        self.displayDelegate = displayDelegate
    }
    
    func viewDidDisappear() {
        readableDelegate.stopIfNeeded()
    }
    
    func getInfo() {
        DispatchQueue.global(qos: .userInitiated).async {
            switch self.detailPostItem.content.contentType {
            case .image, .gif:
                self.getImageGifInfo()
                break
            case .link, .selfPost:
                self.getTextInfo()
                break
            case .richVideo:
                break
            case .titleOnly:
                break
            }
        }
    }
    
    func getTextInfo() {
        if let textPost = self.provider.get() {
            let detailTextVC = vc(storyboardId: String(describing: DetailTextViewController.self)) as! DetailTextViewController
            detailTextVC.textPost = textPost
            
            readableDelegate.setReadingCallback(delegate: detailTextVC)
            
            self.displayDelegate.display(childVC: detailTextVC)
            
            self.readableDelegate.readItem(prefixText: "", readableItem: ReaderContainer(text: textPost.content))
        }
    }
    
    func getImageGifInfo() {
        let detailImageGifVc = vc(storyboardId: String(describing: DetailImageGifViewController.self)) as! DetailImageGifViewController
        
        if let detailImageGifItem = DetailImageGifContainer(title: detailPostItem.title, imageGifUrl: detailPostItem.content.url) {
            detailImageGifVc.imageGifPost = detailImageGifItem
            
            self.displayDelegate.display(childVC: detailImageGifVc)
        }
    }
    
    private func vc(storyboardId: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: storyboardId)
    }
}
