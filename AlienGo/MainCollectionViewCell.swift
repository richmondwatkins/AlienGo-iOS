//
//  MainCollectionViewCell.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(post: DisplayableFeedItem) {
        titleLabel.text = post.postTitle
    }
}
