//
//  DetailViewModel.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol DetailViewModelDelegate: class {
    func display(childVC: UIViewController)
    func present(vc: UIViewController)
}

protocol DetailViewModel {
    var disappearFromCommentPopover: Bool { get set }
    var disappearFromSettings: Bool { get set }
    var detailPostItem: DetailPostItem { get }
    weak var displayDelegate: DetailViewModelDelegate? { get }
    func showComments(press: UILongPressGestureRecognizer)
    func viewDidDisappear()
    func navBack()
    func getInfo()
}

class MainDetailViewModel: DetailViewModel {

    let detailPostItem: DetailPostItem
    weak var displayDelegate: DetailViewModelDelegate?
    var provider: RedditDetailPostProvider!
    var disappearFromCommentPopover: Bool = false
    var disappearFromSettings: Bool = false
    private var readableDelegate: ReadableDelegate = ReadHandler.shared
    private var shouldAcceptLongPress: Bool = true
    var didDisplay: Bool = false
    var showingComments: Bool = false
    
    func set(readableDelegate: ReadableDelegate) {
        self.readableDelegate = readableDelegate
    }
    
    required init(detailPostItem: DetailPostItem, displayDelegate: DetailViewModelDelegate) {
        self.detailPostItem = detailPostItem
        provider = RedditDetailPostProvider(detailPost: detailPostItem)
        self.displayDelegate = displayDelegate
        
        NotificationCenter.default.addObserver(self, selector: #selector(settingsWillShow), name: nSettingsWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(settingsWillHide), name: nSettingsWillHide, object: nil)
        
        getInfo()
    }
    
    func viewDidDisappear() {
        if !showingComments {
            readableDelegate.stop()
        }
        
        showingComments = false
    }
    
    func showComments(press: UILongPressGestureRecognizer) {
        showingComments = true
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
    
    func getInfo() {
        guard !didDisplay else {
            didDisplay = true
            return
        }
        
        self.readableDelegate.readItem(readableItem: ReaderContainer(text: "Loading"), delegate: nil, completion: nil)
        
        let nothingToRead: (@escaping () -> Void) -> Void = {  call in
            let descriptionEnd = StateProvider.isAuto ? "Will display comments" : "Long press for comments"
            self.readableDelegate.readItem(readableItem: ReaderContainer(text: "Image was found without a description. \(descriptionEnd)"), delegate: nil, completion: {
                if StateProvider.isAuto {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                        self.showCommentVC()
                    })
                }
            })
        }
        
        switch self.detailPostItem.content.contentType {
        case .image, .gif, .imageGallery:
            self.getImageGifInfo()
            nothingToRead({})
            break
        case .link, .selfPost:
            self.getTextInfo()
            break
        case .richVideo:
            self.showVideoVC()
            break
        case .titleOnly, .selfPostTitleOnly:
            self.buildTextVC(title: self.detailPostItem.title, text: self.detailPostItem.title)
            break
        }
    }
    
    @objc private func settingsWillShow() {
        disappearFromSettings = true
    }
    
    @objc private func settingsWillHide() {
        disappearFromSettings = true
    }
    
    private func showCommentVC() {
        disappearFromCommentPopover = true
                
        let commentVC: CommentViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: CommentViewController.self)) as! CommentViewController
        commentVC.viewModel = MainCommentViewModel(detailPostItem: detailPostItem, displayDelegate: commentVC)
        
        displayDelegate?.present(vc: commentVC)
    }
    
    private func getTextInfo() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let textPost = self.provider.get() {
                
                if textPost.content.removeAllNewLinesAndSpaces().isEmpty {
                    self.readableDelegate.readItem(readableItem:  ReaderContainer(text: "Could not parse text. Long press for comments"), delegate: nil, completion: nil)
                } else {
                    self.buildTextVC(title: textPost.title, text: textPost.content)
                }
            }
        }
    }
    
    private func buildTextVC(title: String, text: String) {
        let detailTextVC = vc(storyboardId: String(describing: DetailTextViewController.self)) as! DetailTextViewController
        detailTextVC.textPost = DetailTextContainer(title: title, content: text)
        
        self.readableDelegate.readItem(readableItem: ReaderContainer(text: text), delegate: detailTextVC, completion: {
            if StateProvider.isAuto {
                self.showCommentVC()
            }
        })
        
        self.displayDelegate?.display(childVC: detailTextVC)
    }
    
    private func showVideoVC() {
        self.readableDelegate.readItem(readableItem: ReaderContainer(text: "Loading video"), delegate: nil, completion: nil)
        
        let detailVideoVC = vc(storyboardId: String(describing: DetailVideoViewController.self)) as! DetailVideoViewController
        
        if let videoUrl = detailPostItem.content.url {
             detailVideoVC.videoDetailItem = DetailVideoItemContainer(title: detailPostItem.title, videoUrl: videoUrl)
            
            self.displayDelegate?.display(childVC: detailVideoVC)
        }
    }
    
    private func getImageGifInfo() {
        let detailImageGifVc = vc(storyboardId: String(describing: DetailImageGifViewController.self)) as! DetailImageGifViewController
        
        if let detailImageGifItem = DetailImageGifContainer(title: detailPostItem.title, imageGifUrl: detailPostItem.content.url, showInWebView: detailPostItem.content.shouldBeShownInWebView()) {
            detailImageGifVc.imageGifPost = detailImageGifItem
   
            self.displayDelegate?.display(childVC: detailImageGifVc)
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
