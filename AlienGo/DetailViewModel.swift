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
    func present(vc: UIViewController)
}
class DetailViewModel: NSObject {

    let detailPostItem: DetailPostItem
    let displayDelegate: DetailViewModelDelegate
    var provider: RedditDetailPostProvider!
    var disappearFromCommentPopover: Bool = false
    private var readableDelegate: ReadableDelegate = ReadHandler()
    private var shouldAcceptLongPress: Bool = true
    
    func set(readableDelegate: ReadableDelegate) {
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
    
    func showComments(press: UILongPressGestureRecognizer) {
        if press.state == .began && shouldAcceptLongPress {
            
            showCommentVC()
            
            shouldAcceptLongPress = false
        } else if press.state == .ended {
            shouldAcceptLongPress = true
        }
    }
    
    func showCommentVC() {
        disappearFromCommentPopover = true
        
        readableDelegate.stopIfNeeded()
        
        let commentVC: CommentViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: CommentViewController.self)) as! CommentViewController
        commentVC.viewModel = CommentViewModel(detailPostItem: detailPostItem, displayDelegate: commentVC)
        
        displayDelegate.present(vc: commentVC)
    }
    
    func getInfo() {
        DispatchQueue.global(qos: .userInitiated).async {
            switch self.detailPostItem.content.contentType {
            case .image, .gif, .imageGallery:
                self.getImageGifInfo()
                break
            case .link, .selfPost:
                self.getTextInfo()
                break
            case .richVideo:
                self.showVideoVC()
                break
            case .titleOnly, .selfPostTitleOnly:
                let vc = self.buildTextVC(title: self.detailPostItem.title, text: self.detailPostItem.title)
                self.displayDelegate.display(childVC: vc)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { 
                    self.showCommentVC()
                })
                break
            }
        }
    }
    
    func getTextInfo() {
        if let textPost = self.provider.get() {
            
            let vc = buildTextVC(title: textPost.title, text: textPost.content)
            
            readableDelegate.setReadingCallback(delegate: vc)
            
            self.readableDelegate.readItem(prefixText: "", readableItem: ReaderContainer(text: textPost.content))
        }
    }
    
    func buildTextVC(title: String, text: String) -> DetailTextViewController {
        let detailTextVC = vc(storyboardId: String(describing: DetailTextViewController.self)) as! DetailTextViewController
        detailTextVC.textPost = DetailTextContainer(title: title, content: text)
        
        self.displayDelegate.display(childVC: detailTextVC)
        
        return detailTextVC
    }
    
    func showVideoVC() {
         let detailVideoVC = vc(storyboardId: String(describing: DetailVideoViewController.self)) as! DetailVideoViewController
        
        if let videoUrl = detailPostItem.content.url {
             detailVideoVC.videoDetailItem = DetailVideoItemContainer(title: detailPostItem.title, videoUrl: videoUrl)
            
            self.displayDelegate.display(childVC: detailVideoVC)
        }
    }
    
    func getImageGifInfo() {
        let detailImageGifVc = vc(storyboardId: String(describing: DetailImageGifViewController.self)) as! DetailImageGifViewController
        
        if let detailImageGifItem = DetailImageGifContainer(title: detailPostItem.title, imageGifUrl: detailPostItem.content.url, showInWebView: detailPostItem.content.shouldBeShownInWebView()) {
            detailImageGifVc.imageGifPost = detailImageGifItem
            
            self.displayDelegate.display(childVC: detailImageGifVc)
        }
    }
    
    private func vc(storyboardId: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: storyboardId)
    }
}
