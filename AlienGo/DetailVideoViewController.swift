//
//  DetailVideoViewController.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/6/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class DetailVideoViewController: UIViewController {

    @IBOutlet weak var youtubeWebView: RAYoutubeWebView!
    var videoDetailItem: DetailVideoItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        youtubeWebView.urlString = videoDetailItem.videoUrl
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        youtubeWebView.stopVideo()
    }
}
