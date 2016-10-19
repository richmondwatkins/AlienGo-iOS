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

    @IBOutlet weak var imageScrollView: UIScrollView! {
        didSet {
            imageScrollView.minimumZoomScale = 0.5;
            imageScrollView.maximumZoomScale = 6.0;
            imageScrollView.delegate = self
        }
    }
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var imageView: FLAnimatedImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFit
        }
    }
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    var imageGifPost: DetailImageGifItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if imageGifPost.showInWebView {
            view.bringSubview(toFront: webView)
            imageScrollView.isHidden = true
            webView.loadRequest(URLRequest(url: URL(string: imageGifPost.imageGifUrl)!))
        } else {
            view.sendSubview(toBack: webView)
            webView.isHidden = true
            
            imageView.ra_setImageFromUrlString(urlString: imageGifPost.imageGifUrl)
        }
    }
}

extension DetailImageGifViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
