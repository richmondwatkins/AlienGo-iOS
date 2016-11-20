//
//  LoadingLabel.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/19/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class LoadingLabel: UIView {

    lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(ColorConstants.appBlue)
        return label
    }()
    lazy var activityIndicator: UIActivityIndicatorView = {
       let activityIndicator = UIActivityIndicatorView()
        return activityIndicator
    }()
    
    var text: String? {
        get {
            return label.text
        }
        set {
            label.isHidden = false
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            label.text = newValue
            label.sizeToFit()
            invalidateIntrinsicContentSize()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
        
        addSubview(activityIndicator)
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        activityIndicator.frame = bounds
    }
    
    func start() {
        activityIndicator.isHidden = false
        label.text = ""
        label.isHidden = true
        activityIndicator.startAnimating()
        invalidateIntrinsicContentSize()
    }
    
    
    override var intrinsicContentSize: CGSize {
        if activityIndicator.isAnimating {
            return activityIndicator.intrinsicContentSize
        }
        
        return label.intrinsicContentSize
    }
}
