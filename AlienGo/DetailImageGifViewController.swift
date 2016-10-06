//
//  DetailImageGifViewController.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import PINRemoteImage

class DetailImageGifViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var imageView: FLAnimatedImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    var imageGifPost: DetailImageGifItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if imageGifPost.isGif {
            view.bringSubview(toFront: webView)
            webView.loadRequest(URLRequest(url: URL(string: imageGifPost.imageGifUrl)!))
        } else {
            view.sendSubview(toBack: webView)
            imageView.pin_setImage(from: URL(string: imageGifPost.imageGifUrl)) { (result) in
                if let image = result.image {
                    self.imageView.image = image
                    
                    self.imageViewWidthConstraint.constant = image.size.width
                    self.imageViewHeightConstraint.constant = image.size.height
                }
            }
        }
    }
}
