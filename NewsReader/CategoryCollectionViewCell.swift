//
//  CategoryCollectionViewCell.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/13/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol CategoryCollectionViewCellDelegate: class {
    func didSelect(category: Category)
}

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    weak var delegate: CategoryCollectionViewCellDelegate!
    var cateogry: Category!
    
    override func awakeFromNib() {
        super.awakeFromNib ()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 2
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor(ColorConstants.appBlue).cgColor
    }

    func configure(cateogry: Category, delegate: CategoryCollectionViewCellDelegate) {
        self.delegate = delegate
        self.cateogry = cateogry
        mainTitleLabel.text = cateogry.name
    }
    
    func setButtonImage(isSubscribed: Bool) {
        if isSubscribed {
            subscribeButton.setImage(#imageLiteral(resourceName: "subscribe_f"), for: .normal)
        } else {
            subscribeButton.setImage(#imageLiteral(resourceName: "subscribe"), for: .normal)
        }
    }
    
    @IBAction func didSelectSubscribeButton(_ sender: UIButton) {
        self.cateogry.setSubscribed(subscribed: !self.cateogry.getSubscribed())
        setButtonImage(isSubscribed: self.cateogry.getSubscribed())
        
        self.delegate.didSelect(category: self.cateogry)
    }
}
