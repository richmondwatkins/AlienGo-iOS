//
//  SpeechVolumeCellTableViewCell.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/20/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class SpeechVolumeCellTableViewCell: UITableViewCell {

    @IBOutlet weak var sliderControl: UISlider!
    weak var readDelegate: ReadableDelegate? = ReadHandler.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sliderControl.setValue(UserInfo.utteranceSpeed, animated: true)
    }
    
    @IBAction func didSlide(_ sender: UISlider) {
        UserInfo.utteranceSpeed = sender.value
        
        readDelegate?.readItem(readableItem: ReaderContainer(text: "The quick brown fox jumps over the lazy dog"), delegate: nil, completion: nil)
    }
}
