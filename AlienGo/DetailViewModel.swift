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
class DetailViewModel {

    let detailPostItem: DetailPostItem
    let displayDelegate: DetailViewModelDelegate
    var provider: RedditDetailPostProvider!
    var disappearFromCommentPopover: Bool = false
    var disappearFromSettings: Bool = false
    private var readableDelegate: ReadableDelegate = ReadHandler.shared
    private var shouldAcceptLongPress: Bool = true
    
    func set(readableDelegate: ReadableDelegate) {
        self.readableDelegate = readableDelegate
    }
    
    init(detailPostItem: DetailPostItem, displayDelegate: DetailViewModelDelegate) {
        self.detailPostItem = detailPostItem
        provider = RedditDetailPostProvider(detailPost: detailPostItem)
        self.displayDelegate = displayDelegate
        
        NotificationCenter.default.addObserver(self, selector: #selector(settingsWillShow), name: nSettingsWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(settingsWillHide), name: nSettingsWillHide, object: nil)
    }
    
    func viewDidDisappear() {
        readableDelegate.stop()
    }
    
    func showComments(press: UILongPressGestureRecognizer) {
        if press.state == .began && shouldAcceptLongPress {
            
            showCommentVC()
            
            shouldAcceptLongPress = false
        } else if press.state == .ended {
            shouldAcceptLongPress = true
        }
    }
    
    func navBack() {
        readableDelegate.hardStop()
    }
    
    @objc func settingsWillShow() {
        disappearFromSettings = true
    }
    
    @objc func settingsWillHide() {
        disappearFromSettings = true
    }
    
    func showCommentVC() {
        disappearFromCommentPopover = true
                
        let commentVC: CommentViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: CommentViewController.self)) as! CommentViewController
        commentVC.viewModel = CommentViewModel(detailPostItem: detailPostItem, displayDelegate: commentVC)
        
        displayDelegate.present(vc: commentVC)
    }
    
    func getInfo() {
        self.readableDelegate.readItem(readableItem: ReaderContainer(text: "Loading"), delegate: nil, completion: nil)
        
        let nothingToRead: (@escaping () -> Void) -> Void = {  call in
            self.readableDelegate.readItem(readableItem: ReaderContainer(text: "Nothing to read. Will display comments"), delegate: nil, completion: {
                call()
            })
        }
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.4, execute: {
            switch self.detailPostItem.content.contentType {
            case .image, .gif, .imageGallery:
                
                nothingToRead({ 
                    self.getImageGifInfo()
                    self.showCommentVC()
                })
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
        })
    }
    
    func getTextInfo() {
        if let textPost = self.provider.get() {
            
            if textPost.content.removeAllNewLinesAndSpaces().isEmpty {
                self.readableDelegate.readItem(readableItem:  ReaderContainer(text: "Could not parse text. Long press for comments"), delegate: nil, completion: nil)
            } else {
                let vc = self.buildTextVC(title: textPost.title, text: textPost.content)
                
                self.readableDelegate.readItem(readableItem: ReaderContainer(text: textPost.content), delegate: vc, completion: {
                    if StateProvider.isAuto {
                        self.showCommentVC()
                    }
                })
            }
        }
    }
    
    func buildTextVC(title: String, text: String) -> DetailTextViewController {
        let detailTextVC = vc(storyboardId: String(describing: DetailTextViewController.self)) as! DetailTextViewController
        detailTextVC.textPost = DetailTextContainer(title: title, content: text)
        
        self.displayDelegate.display(childVC: detailTextVC)
        
        return detailTextVC
    }
    
    func showVideoVC() {
        self.readableDelegate.readItem(readableItem: ReaderContainer(text: "Loading video"), delegate: nil, completion: nil)
        
        let detailVideoVC = vc(storyboardId: String(describing: DetailVideoViewController.self)) as! DetailVideoViewController
        
        if let videoUrl = detailPostItem.content.url {
             detailVideoVC.videoDetailItem = DetailVideoItemContainer(title: detailPostItem.title, videoUrl: videoUrl)
            
            self.displayDelegate.display(childVC: detailVideoVC)
        }
    }
    
    func getImageGifInfo() {
        self.readableDelegate.readItem(readableItem: ReaderContainer(text: "Loading"), delegate: nil, completion: nil)
        
        let detailImageGifVc = vc(storyboardId: String(describing: DetailImageGifViewController.self)) as! DetailImageGifViewController
        
        if let detailImageGifItem = DetailImageGifContainer(title: detailPostItem.title, imageGifUrl: detailPostItem.content.url, showInWebView: detailPostItem.content.shouldBeShownInWebView()) {
            detailImageGifVc.imageGifPost = detailImageGifItem
            
            if StateProvider.isAuto {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: { 
                    self.showCommentVC()
                })
            }
            
            self.displayDelegate.display(childVC: detailImageGifVc)
        }
    }
    
    private func vc(storyboardId: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: storyboardId)
    }
}

extension String {
    
    func removeAllNewLinesAndSpaces() -> String {
        let trimmed = self.replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression)
        return trimmed.replacingOccurrences(of: "^\\n*", with: "", options: .regularExpression)
    }
}
