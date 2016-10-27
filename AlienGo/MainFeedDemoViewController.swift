//
//  MainFeedDemoViewController.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/25/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class MainFeedDemoViewController: UIViewController {

    @IBOutlet var viewModel: RedditPostListingViewModel!
    var didReturnFromDetail: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.collectionSource.collectionView.isScrollEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if didReturnFromDetail && self.parent! is UINavigationController {
            ((self.parent! as! UINavigationController).parent as! PostNavigationDemoViewController).finish()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didReturnFromDetail = true
    }
}
