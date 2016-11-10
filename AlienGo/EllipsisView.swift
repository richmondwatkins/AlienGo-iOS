//
//  EllipsisView.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/2/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol EllipsisSelectionDelegate {
    func didSelect()
}

class EllipsisView: UIView {

    let one: UIView = UIView()
    let two: UIView = UIView()
    let three: UIView = UIView()
    let sideInset: CGFloat = 10
    let spacing: CGFloat = 10
    let borderColor: CGColor = UIColor.white.cgColor
    var selectionDelegate: EllipsisSelectionDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        sharedInit()
    }
    
    func sharedInit() {
        addSubview(one)
        addSubview(two)
        addSubview(three)
        
        one.layer.borderColor = borderColor
        two.layer.borderColor = borderColor
        three.layer.borderColor = borderColor
        
        one.layer.borderWidth = 1.0
        two.layer.borderWidth = 1.0
        three.layer.borderWidth = 1.0
        
        let touch: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTouch))
        touch.numberOfTapsRequired = 1
        
        self.addGestureRecognizer(touch)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = (frame.width - (sideInset * 2) - (spacing * 2)) / 3
        let height = width
        let y = frame.height / 2 - height / 2
        
        one.frame = CGRect(x: 0, y: y, width: width, height: height)
        two.frame = CGRect(x: one.frame.origin.x + one.frame.width + spacing, y: y, width: width, height: height)
        three.frame = CGRect(x: two.frame.origin.x + two.frame.width + spacing, y: y, width: width, height: height)
        
        let cornerRadius = height / 2
        
        one.layer.cornerRadius = cornerRadius
        two.layer.cornerRadius = cornerRadius
        three.layer.cornerRadius = cornerRadius
    }
    
    func didTouch() {
        selectionDelegate?.didSelect()
    }
}
